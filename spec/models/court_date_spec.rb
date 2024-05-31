require "rails_helper"

RSpec.describe CourtDate, type: :model do
  subject(:court_date) { create(:court_date, casa_case: casa_case) }

  let(:casa_case) { create(:casa_case, case_number: "AAA123123") }
  let(:volunteer) { create(:volunteer, casa_org: casa_case.casa_org) }
  let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }
  let(:this_court_date) { subject.date }
  let(:older_court_date) { subject.date - 6.months }
  let(:path_to_template) { Rails.root.join("app", "documents", "templates", "default_report_template.docx").to_s }
  let(:path_to_report) { Rails.root.join("tmp", "test_report.docx").to_s }

  it { is_expected.to belong_to(:casa_case) }
  it { is_expected.to validate_presence_of(:date) }
  it { is_expected.to have_many(:case_court_orders) }
  it { is_expected.to belong_to(:hearing_type).optional }
  it { is_expected.to belong_to(:judge).optional }

  before do
    travel_to Date.new(2021, 1, 1)
  end

  describe "date validation" do
    it "is not valid before 1989" do
      court_date = CourtDate.new(date: "1984-01-01".to_date)
      expect(court_date.valid?).to be false
      expect(court_date.errors[:date]).to eq(["is not valid. Court date cannot be prior to 1/1/1989."])
    end

    fit "is not valid more than 1 year in the future" do
      court_date = CourtDate.new(date: 367.days.from_now)
      expect(court_date.valid?).to be false
      expect(court_date.errors[:date]).to eq(["is not valid. Court date must be within one year from today."])
    end

    it "is valid within one year in the future" do
      court_date = CourtDate.new(date: 6.months.from_now)
      court_date.valid?
      expect(court_date.errors[:date]).to eq([])
    end

    it "is valid in the past after 1989" do
      court_date = CourtDate.new(date: "1997-08-29".to_date)
      court_date.valid?
      expect(court_date.errors[:date]).to eq([])
    end
  end

  it "is invalid without a casa_case" do
    court_date = build(:court_date, casa_case: nil)
    expect do
      court_date.casa_case = casa_case
    end.to change { court_date.valid? }.from(false).to(true)
  end

  describe ".ordered_ascending" do
    subject { described_class.ordered_ascending }

    it "orders the casa cases by updated at date" do
      very_old_pcd = create(:court_date, date: 10.days.ago)
      old_pcd = create(:court_date, date: 5.day.ago)
      recent_pcd = create(:court_date, date: 1.day.ago)

      ordered_pcds = described_class.ordered_ascending

      expect(ordered_pcds.map(&:id)).to eq [very_old_pcd.id, old_pcd.id, recent_pcd.id]
    end
  end

  describe "reports" do
    let!(:reports) do
      [10, 30, 60].map do |days_ago|
        path_to_template = "app/documents/templates/default_report_template.docx"
        args = {
          case_id: casa_case.id,
          volunteer_id: volunteer.id,
          path_to_template: path_to_template
        }
        context = CaseCourtReportContext.new(args).context
        report = CaseCourtReport.new(path_to_template: path_to_template, context: context)
        casa_case.court_reports.attach(io: StringIO.new(report.generate_to_string), filename: "report-#{days_ago}.docx")
        attached_report = casa_case.latest_court_report
        attached_report.created_at = days_ago.days.ago
        attached_report.save!
        attached_report
      end
    end
    let(:ten_days_ago_report) { reports[0] }
    let(:thirty_days_ago_report) { reports[1] }
    let(:sixty_days_ago_report) { reports[2] }

    describe "#associated_reports" do
      subject(:associated_reports) { court_date.associated_reports }

      context "without other court dates" do
        it { is_expected.to eq [ten_days_ago_report, thirty_days_ago_report, sixty_days_ago_report] }
      end

      context "with a previous court date" do
        let!(:other_court_date) { create(:court_date, casa_case: casa_case, date: 40.days.ago) }

        it { is_expected.to eq [ten_days_ago_report, thirty_days_ago_report] }
      end
    end

    describe "#latest_associated_report" do
      it "is the most recent report for the case" do
        expect(subject.latest_associated_report).to eq(ten_days_ago_report)
      end
    end
  end

  describe "#additional_info?" do
    subject(:additional_info) { court_date.additional_info? }
    context "with orders" do
      it "returns true" do
        create(:case_court_order, casa_case: casa_case, court_date: court_date)
        expect(subject).to be_truthy
      end
    end

    context "with hearing type" do
      it "returns true" do
        hearing_type = create(:hearing_type)
        court_date.update!(hearing_type_id: hearing_type.id)
        expect(subject).to be_truthy
      end
    end

    context "with judge" do
      it "returns true" do
        judge = create(:judge)
        court_date.update!(judge_id: judge.id)
        expect(subject).to be_truthy
      end
    end

    context "with no extra data" do
      it "returns false" do
        expect(subject).to be_falsy
      end
    end
  end

  describe "#display_name" do
    subject { court_date.display_name }
    it "contains case number and date" do
      travel_to Time.zone.local(2020, 1, 2)
      expect(subject).to eq("AAA123123 - Court Date - 2019-12-26")
    end
  end
end

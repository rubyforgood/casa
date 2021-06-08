require "rails_helper"

RSpec.describe PastCourtDate, type: :model do
  describe "validations" do
    it { is_expected.to belong_to(:casa_case) }
    it { is_expected.to belong_to(:hearing_type).optional(true) }
    it { is_expected.to belong_to(:judge).optional(true) }
  end

  describe "methods" do
    let(:past_court_date) { build_stubbed(:past_court_date) }

    describe "reports methods" do
      let(:past_court_date) { create(:past_court_date, casa_case: casa_case) }

      let(:volunteer) { create(:volunteer) }
      let(:casa_case) { create(:casa_case, casa_org: volunteer.casa_org) }
      let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }

      let!(:reports) do
        [10, 30, 60].map do |n|
          report = CaseCourtReport.new(
            volunteer_id: volunteer.id,
            case_id: casa_case.id,
            path_to_template: "app/documents/templates/default_report_template.docx"
          )
          casa_case.court_reports.attach(io: StringIO.new(report.generate_to_string), filename: "report#{n}.docx")
          attached_report = casa_case.latest_court_report
          attached_report.created_at = n.days.ago

          attached_report.save!
          attached_report
        end
      end

      describe "#associated_reports" do
        subject(:associated_reports) { past_court_date.associated_reports }

        context "without other court dates" do
          it { is_expected.to eq reports }
        end

        context "with a previous court date" do
          let!(:other_past_court_date) { create(:past_court_date, casa_case: casa_case, date: 40.days.ago) }

          it { is_expected.to eq [reports[0], reports[1]] }
        end
      end

      describe "#latest_associated_report" do
        subject(:latest_associated_report) { past_court_date.latest_associated_report }

        it { is_expected.to eq past_court_date.associated_reports.order(:created_at).last }
      end
    end

    describe "#additional_info?" do
      subject(:additional_info?) { past_court_date.additional_info? }

      context "without court details" do
        it { is_expected.to be_falsy }
      end

      context "with court details" do
        context "with judge" do
          before { past_court_date.judge = build_stubbed(:judge) }

          it { is_expected.to be_truthy }
        end

        context "with hearing type" do
          before { past_court_date.hearing_type = build_stubbed(:hearing_type) }

          it { is_expected.to be_truthy }
        end

        context "with both judge and hearing type" do
          before do
            past_court_date.judge = build_stubbed(:judge)
            past_court_date.hearing_type = build_stubbed(:hearing_type)
          end

          it { is_expected.to be_truthy }
        end
      end
    end

    describe "#generate_report" do
      subject(:generate_report) { past_court_date.generate_report }

      it { is_expected.not_to be_nil }
    end

    describe "#display_name" do
      subject(:display_name) { past_court_date.display_name }

      let(:casa_case) { build_stubbed(:casa_case, case_number: "CINA-000") }
      let(:past_court_date) { build_stubbed(:past_court_date, casa_case: casa_case, date: Time.zone.local(2020, 5, 3)) }

      it { is_expected.to eq "CINA-000 - Past Court Date - 2020-05-03" }
    end
  end

  it "has a valid factory" do
    past_court_date = build(:past_court_date)
    expect(past_court_date.valid?).to be_truthy
  end
end

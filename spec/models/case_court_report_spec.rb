require "rails_helper"
require "sablon"

RSpec.describe CaseCourtReport, type: :model do
  let(:volunteer) { create(:volunteer, :with_cases_and_contacts, :with_assigned_supervisor) }

  describe "when receiving valid case, volunteer, and path_to_template" do
    let(:casa_case_without_contacts) { volunteer.casa_cases.second }
    let(:casa_case_with_contacts) { volunteer.casa_cases.first }
    let(:path_to_template) { "app/documents/templates/default_report_template.docx" }
    let(:path_to_report) { "tmp/test_report.docx" }
    let(:report) do
      CaseCourtReport.new(
        case_id: casa_case_with_contacts.id,
        volunteer_id: volunteer.id,
        path_to_template: path_to_template,
        path_to_report: path_to_report
      )
    end

    describe "With volunteer without supervisor" do
      let(:volunteer) { create(:volunteer, :with_cases_and_contacts) }

      it "has supervisor name placeholder" do
        expect(report.context[:volunteer][:supervisor_name]).to eq("")
      end
    end

    describe "with court date in the future" do
      let!(:far_past_case_contact) { create :case_contact, occurred_at: 5.days.ago, casa_case_id: casa_case_with_contacts.id }

      before do
        casa_case_with_contacts.update!(court_date: 1.day.from_now)
      end

      describe "without past court date" do
        it "has all case contacts ever created for the youth" do
          expect(report.context[:case_contacts].length).to eq(5)
        end
      end

      describe "with past court date" do
        # TODO make a factory for PastCourtDate
        let!(:past_court_date) { PastCourtDate.create!(date: 2.days.ago, casa_case_id: casa_case_with_contacts.id) }

        it "has all case contacts created since the previous court date" do
          expect(casa_case_with_contacts.past_court_dates.length).to eq(1)
          expect(report.context[:case_contacts].length).to eq(4)
        end
      end
    end

    describe "has valid @context" do
      subject { report.context }

      it { is_expected.not_to be_empty }
      it { is_expected.to be_instance_of Hash }

      it "has the following keys [:created_date, :casa_case, :case_contacts, :volunteer]" do
        expected = %i[created_date casa_case case_contacts volunteer]
        expect(subject.keys).to include(*expected)
      end

      it "must have Case Contacts as type Array" do
        expect(subject[:case_contacts]).to be_instance_of Array
      end

      it "created_date is not nil" do
        expect(subject[:created_date]).to_not be(nil)
      end
    end

    describe "when generating report" do
      it "successfully generates to memory as a String instance" do
        report_as_data = report.generate_to_string

        expect(report_as_data).not_to be_nil
        expect(report_as_data).to be_instance_of String
      end
    end
  end

  describe "when receiving INVALID path_to_template" do
    let(:casa_case_with_contacts) { volunteer.casa_cases.first }
    let(:nonexistent_path) { "app/documents/templates/nonexisitent_report_template.docx" }

    it "will raise Zip::Error when generating report" do
      bad_report = CaseCourtReport.new(
        case_id: casa_case_with_contacts.id,
        volunteer_id: volunteer.id,
        path_to_template: nonexistent_path
      )
      expect { bad_report.generate_to_string }.to raise_error(Zip::Error)
    end
  end
end

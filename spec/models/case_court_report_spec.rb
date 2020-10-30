require "rails_helper"
require "sablon"

RSpec.describe CaseCourtReport, type: :model do
  let(:volunteer) { create(:volunteer, :with_cases_and_contacts, :with_assigned_supervisor) }
  let(:casa_case_without_contacts) { volunteer.casa_cases.second }

  describe "when receiving valid case, volunteer, and path_to_template" do
    let(:casa_case_with_contacts) { volunteer.casa_cases.first }
    let(:path_to_template) { "app/documents/templates/report_template_transition.docx" }
    let(:path_to_report) { "tmp/test_report.docx" }
    let(:report) do
      CaseCourtReport.new(
        case_id: casa_case_with_contacts.id,
        volunteer_id: volunteer.id,
        path_to_template: path_to_template,
        path_to_report: path_to_report
      )
    end

    describe "has valid @path_to_template" do
      it "is existing" do
        path = report.template.instance_variable_get(:@path)

        expect(File.exist?(path_to_template)).to eq true
        expect(File.exist?(path)).to eq true
      end
    end

    describe "has valid @context" do
      subject { report.context }

      it { is_expected.not_to be_empty }
      it { is_expected.to be_instance_of Hash }

      it "has the following keys [:created_date, :casa_case, :case_contacts, :volunteer]" do
        expected = %i[created_date casa_case case_contacts volunteer]
        expect(subject.keys).to eq expected
      end

      it "must have Case Contacts as type Array" do
        expect(subject[:case_contacts]).to be_instance_of Array
      end
    end

    describe "when generating report" do
      it "successfully generates to memory as a String instance" do
        report_as_data = report.generate_to_string

        expect(report_as_data).not_to be_nil
        expect(report_as_data).to be_instance_of String
      end

      it "successfully generates to file" do
        report.generate!

        expect(File.exist?(path_to_report)).to eq true
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

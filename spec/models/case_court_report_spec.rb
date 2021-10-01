require "rails_helper"
require "sablon"

RSpec.describe CaseCourtReport, type: :model do
  let(:path_to_template) { Rails.root.join("app", "documents", "templates", "default_report_template.docx").to_s }
  let(:path_to_report) { Rails.root.join("tmp", "test_report.docx").to_s }

  describe "when receiving valid case, volunteer, and path_to_template" do
    let(:volunteer) { create(:volunteer, :with_cases_and_contacts, :with_assigned_supervisor) }
    let(:casa_case_with_contacts) { volunteer.casa_cases.first }
    let(:casa_case_without_contacts) { volunteer.casa_cases.second }
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
        let!(:past_court_date) { create(:past_court_date, date: 2.days.ago, casa_case_id: casa_case_with_contacts.id) }

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

      it "has the following keys [:created_date, :casa_case, :case_contacts, :latest_hearing_date, :org_address, :volunteer]" do
        expected = %i[created_date casa_case case_contacts volunteer]
        expect(subject.keys).to include(*expected)
      end

      it "must have Case Contacts as type Array" do
        expect(subject[:case_contacts]).to be_instance_of Array
      end

      it "created_date is not nil" do
        expect(subject[:created_date]).to_not be(nil)
      end

      context "when the case has multiple past court dates" do
        before do
          casa_case_with_contacts.past_court_dates << create(:past_court_date, date: 9.months.ago)
          casa_case_with_contacts.past_court_dates << create(:past_court_date, date: 3.months.ago)
          casa_case_with_contacts.past_court_dates << create(:past_court_date, date: 15.months.ago)
        end

        it "sets latest_hearing_date as the latest past court date" do
          expect(subject[:latest_hearing_date]).to eq(I18n.l(3.months.ago, format: :full, default: nil))
        end
      end
    end

    describe "the default generated report" do
      context "when passed all displayable information" do
        let(:document_data) do
          {
            case_birthday: 12.years.ago,
            case_contact_time: 3.days.ago,
            case_contact_type: "Unique Case Contact Type",
            case_hearing_date: 2.weeks.from_now,
            case_number: "A-CASA-CASE-NUMBER-12345",
            mandate_text: "This text shall not be strikingly similar to other text in the document",
            org_address: "596 Unique Avenue Seattle, Washington",
            supervisor_name: "A very unique supervisor name",
            volunteer_case_assignment_date: 2.months.ago,
            volunteer_name: "An unmistakably unique volunteer name"
          }
        end

        let(:contact_type) { create(:contact_type, name: document_data[:case_contact_type]) }
        let(:case_contact) { create(:case_contact, contact_made: false, occurred_at: document_data[:case_contact_time]) }
        let(:court_mandate) { create(:case_court_mandate, implementation_status: :partially_implemented) }

        before(:each) do
          casa_case_with_contacts.casa_org.update_attribute(:address, document_data[:org_address])
          casa_case_with_contacts.update_attribute(:birth_month_year_youth, document_data[:case_birthday])
          casa_case_with_contacts.update_attribute(:case_number, document_data[:case_number])
          casa_case_with_contacts.update_attribute(:court_date, document_data[:case_hearing_date])
          case_contact.contact_types << contact_type
          casa_case_with_contacts.case_contacts << case_contact
          casa_case_with_contacts.case_court_mandates << court_mandate
          court_mandate.update_attribute(:mandate_text, document_data[:mandate_text])
          CaseAssignment.find_by(casa_case_id: casa_case_with_contacts.id, volunteer_id: volunteer.id).update_attribute(:created_at, document_data[:volunteer_case_assignment_date])
          volunteer.update_attribute(:display_name, document_data[:volunteer_name])
          volunteer.supervisor.update_attribute(:display_name, document_data[:supervisor_name])
        end

        it "displays all the information" do
          report_as_raw_docx = report.generate_to_string
          report_top_header = get_docx_subfile_contents(report_as_raw_docx, "word/header3.xml")
          report_body = get_docx_subfile_contents(report_as_raw_docx, "word/document.xml")

          expect(report_top_header).to include(document_data[:org_address])
          expect(report_body).to include(Date.today.strftime("%B %-d, %Y"))
          expect(report_body).to include(document_data[:case_hearing_date].strftime("%B %-d, %Y"))
          expect(report_body).to include(document_data[:case_number])
          expect(report_body).to include(document_data[:case_contact_type])
          expect(report_body).to include("#{document_data[:case_contact_time].strftime("%-m/%d")}*")
          expect(report_body).to include(document_data[:mandate_text])
          expect(report_body).to include("Partially implemented") # Mandate Status
          expect(report_body).to include(document_data[:volunteer_name])
          expect(report_body).to include(document_data[:volunteer_case_assignment_date].strftime("%B %-d, %Y"))
          expect(report_body).to include(document_data[:supervisor_name])
        end
      end

      context "when missing a volunteer" do
        let(:report) do
          CaseCourtReport.new(
            case_id: casa_case.id,
            volunteer_id: nil,
            path_to_template: path_to_template,
            path_to_report: path_to_report
          )
        end

        let(:document_data) do
          {
            case_birthday: 12.years.ago,
            case_contact_time: 3.days.ago,
            case_contact_type: "Unique Case Contact Type",
            case_hearing_date: 2.weeks.from_now,
            case_number: "A-CASA-CASE-NUMBER-12345",
            mandate_text: "This text shall not be strikingly similar to other text in the document",
            org_address: nil,
            supervisor_name: nil,
            volunteer_case_assignment_date: 2.months.ago,
            volunteer_name: nil
          }
        end

        let(:casa_case) { create(:casa_case) }
        let(:contact_type) { create(:contact_type, name: document_data[:case_contact_type]) }
        let(:case_contact) { create(:case_contact, contact_made: false, occurred_at: document_data[:case_contact_time]) }
        let(:court_mandate) { create(:case_court_mandate, implementation_status: :partially_implemented) }

        before(:each) do
          casa_case.casa_org.update_attribute(:address, document_data[:org_address])
          casa_case.update_attribute(:birth_month_year_youth, document_data[:case_birthday])
          casa_case.update_attribute(:case_number, document_data[:case_number])
          casa_case.update_attribute(:court_date, document_data[:case_hearing_date])
          case_contact.contact_types << contact_type
          casa_case.case_contacts << case_contact
          casa_case.case_court_mandates << court_mandate
          court_mandate.update_attribute(:mandate_text, document_data[:mandate_text])
        end

        it "display all expected information" do
          report_as_raw_docx = report.generate_to_string
          report_body = get_docx_subfile_contents(report_as_raw_docx, "word/document.xml")

          expect(report_body).to include(Date.today.strftime("%B %-d, %Y"))
          expect(report_body).to include(document_data[:case_hearing_date].strftime("%B %-d, %Y"))
          expect(report_body).to include(document_data[:case_number])
          expect(report_body).to include(document_data[:case_contact_type])
          expect(report_body).to include("#{document_data[:case_contact_time].strftime("%-m/%d")}*")
          expect(report_body).to include(document_data[:mandate_text])
          expect(report_body).to include("Partially implemented") # Mandate Status
        end
      end
    end
  end

  describe "when receiving INVALID path_to_template" do
    let(:volunteer) { create(:volunteer, :with_cases_and_contacts, :with_assigned_supervisor) }
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

  describe "when court mandates has different implementation statuses" do
    let(:casa_case) { create(:casa_case, case_number: "Sample-Case-12345") }
    let(:court_mandate_implemented) { create(:case_court_mandate, casa_case: casa_case, mandate_text: "This order is implemented already", implementation_status: :implemented) }
    let(:court_mandate_not_implemented) { create(:case_court_mandate, casa_case: casa_case, mandate_text: "This order is not implemented yet", implementation_status: :not_implemented) }
    let(:court_mandate_partially_implemented) { create(:case_court_mandate, casa_case: casa_case, mandate_text: "This order is partially implemented", implementation_status: :partially_implemented) }
    let(:court_mandate_not_specified) { create(:case_court_mandate, casa_case: casa_case, mandate_text: "This order does not have any implementation status", implementation_status: nil) }

    before(:each) do
      casa_case.case_court_mandates << court_mandate_implemented
      casa_case.case_court_mandates << court_mandate_not_implemented
      casa_case.case_court_mandates << court_mandate_partially_implemented
      casa_case.case_court_mandates << court_mandate_not_specified
    end

    it "should have all the court mandates" do
      case_report = CaseCourtReport.new(
        case_id: casa_case.id,
        path_to_template: path_to_template,
        path_to_report: path_to_report
      )
      case_report_body = get_docx_subfile_contents(case_report.generate_to_string, "word/document.xml")

      expect(case_report_body).to include(casa_case.case_number)

      expect(case_report_body).to include(court_mandate_implemented.mandate_text)
      expect(case_report_body).to include("Implemented")

      expect(case_report_body).to include(court_mandate_not_implemented.mandate_text)
      expect(case_report_body).to include("Not implemented")

      expect(case_report_body).to include(court_mandate_partially_implemented.mandate_text)
      expect(case_report_body).to include("Partially implemented")

      expect(case_report_body).to include(court_mandate_partially_implemented.mandate_text)
      expect(case_report_body).to include("Not specified")
    end
  end
end

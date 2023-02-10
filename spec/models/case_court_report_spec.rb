# frozen_string_literal: true

require "rails_helper"
require "sablon"

RSpec.describe CaseCourtReport, type: :model do
  let(:path_to_template) { Rails.root.join("app", "documents", "templates", "default_report_template.docx").to_s }
  let(:path_to_report) { Rails.root.join("tmp", "test_report.docx").to_s }

  context "#generate_to_string" do
    describe "when receiving valid case, volunteer, and path_to_template" do
      let(:volunteer) { create(:volunteer, :with_cases_and_contacts, :with_assigned_supervisor) }
      let(:casa_case_with_contacts) { volunteer.casa_cases.first }
      let(:casa_case_without_contacts) { volunteer.casa_cases.second }
      let(:report) do
        args = {
          case_id: casa_case_with_contacts.id,
          volunteer_id: volunteer.id,
          path_to_template: path_to_template,
          path_to_report: path_to_report
        }
        context = CaseCourtReportContext.new(args).context
        CaseCourtReport.new(path_to_template: path_to_template, context: context)
      end

      describe "with volunteer without supervisor" do
        let(:volunteer) { create(:volunteer, :with_cases_and_contacts) }

        it "has supervisor name placeholder" do
          expect(report.context[:volunteer][:supervisor_name]).to eq("")
        end
      end

      describe "with court date in the future" do
        let!(:far_past_case_contact) { create :case_contact, occurred_at: 5.days.ago, casa_case_id: casa_case_with_contacts.id }

        before do
          create(:court_date, casa_case: casa_case_with_contacts, date: 1.day.from_now)
        end

        describe "without past court date" do
          it "has all case contacts ever created for the youth" do
            expect(report.context[:case_contacts].length).to eq(5)
          end
        end

        describe "with past court date" do
          let!(:court_date) { create(:court_date, date: 2.days.ago, casa_case_id: casa_case_with_contacts.id) }

          it "has all case contacts created since the previous court date including case contact created on the court date" do
            create(:case_contact, casa_case: casa_case_with_contacts, created_at: court_date.date, notes: "created ON most recent court date")
            expect(casa_case_with_contacts.court_dates.length).to eq(2)
            expect(report.context[:case_contacts].length).to eq(5)
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
            casa_case_with_contacts.court_dates << create(:court_date, date: 9.months.ago)
            casa_case_with_contacts.court_dates << create(:court_date, date: 3.months.ago)
            casa_case_with_contacts.court_dates << create(:court_date, date: 15.months.ago)
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
              text: "This text shall not be strikingly similar to other text in the document",
              org_address: "596 Unique Avenue Seattle, Washington",
              supervisor_name: "A very unique supervisor name",
              volunteer_case_assignment_date: 2.months.ago,
              volunteer_name: "An unmistakably unique volunteer name"
            }
          end

          let(:contact_type) { create(:contact_type, name: document_data[:case_contact_type]) }
          let(:case_contact) { create(:case_contact, contact_made: false, occurred_at: document_data[:case_contact_time]) }
          let(:court_order) { create(:case_court_order, implementation_status: :partially_implemented) }
          let(:document_inspector) { DocxInspector.new(docx_contents: report.generate_to_string) }

          before(:each) do
            casa_case_with_contacts.casa_org.update_attribute(:address, document_data[:org_address])
            casa_case_with_contacts.update_attribute(:birth_month_year_youth, document_data[:case_birthday])
            casa_case_with_contacts.update_attribute(:case_number, document_data[:case_number])
            create(:court_date, casa_case: casa_case_with_contacts, date: document_data[:case_hearing_date])
            case_contact.contact_types << contact_type
            casa_case_with_contacts.case_contacts << case_contact
            casa_case_with_contacts.case_court_orders << court_order
            court_order.update_attribute(:text, document_data[:text])
            CaseAssignment.find_by(casa_case_id: casa_case_with_contacts.id, volunteer_id: volunteer.id).update_attribute(:created_at, document_data[:volunteer_case_assignment_date])
            volunteer.update_attribute(:display_name, document_data[:volunteer_name])
            volunteer.supervisor.update_attribute(:display_name, document_data[:supervisor_name])
          end

          it "displays the org address" do
            expect(document_inspector.word_list_header_contains?(document_data[:org_address])).to eq(true)
          end

          it "displays today's date formatted" do
            expect(document_inspector.word_list_document_contains?(Date.today.strftime("%B %-d, %Y"))).to eq(true)
          end

          it "displays the case hearing date date formatted" do
            expect(document_inspector.word_list_document_contains?(document_data[:case_hearing_date].strftime("%B %-d, %Y"))).to eq(true)
          end

          it "displays the case number" do
            expect(document_inspector.word_list_document_contains?(document_data[:case_number])).to eq(true)
          end

          it "displays th case contact type" do
            expect(document_inspector.word_list_document_contains?(document_data[:case_contact_type])).to eq(true)
          end

          it "displays the case contact tiime date formatted" do
            expect(document_inspector.word_list_document_contains?("#{document_data[:case_contact_time].strftime("%-m/%d")}*")).to eq(true)
          end

          it "displays the text" do
            expect(document_inspector.word_list_document_contains?(document_data[:text])).to eq(true)
          end

          it "displays the order status" do
            expect(document_inspector.word_list_document_contains?("Partially implemented")).to eq(true) # Order Status
          end

          it "displays the volunteer name" do
            expect(document_inspector.word_list_document_contains?(document_data[:volunteer_name])).to eq(true)
          end

          it "displays the volunteer case assignment date formatted" do
            expect(document_inspector.word_list_document_contains?(document_data[:volunteer_case_assignment_date].strftime("%B %-d, %Y"))).to eq(true)
          end

          it "displayes the supervisor name" do
            expect(document_inspector.word_list_document_contains?(document_data[:supervisor_name])).to eq(true)
          end
        end

        context "when missing a volunteer" do
          let(:report) do
            args = {
              case_id: casa_case.id,
              volunteer_id: nil,
              path_to_template: path_to_template,
              path_to_report: path_to_report
            }
            context = CaseCourtReportContext.new(args).context
            CaseCourtReport.new(path_to_template: path_to_template, context: context)
          end

          let(:document_data) do
            {
              case_birthday: 12.years.ago,
              case_contact_time: 3.days.ago,
              case_contact_type: "Unique Case Contact Type",
              case_hearing_date: 2.weeks.from_now,
              case_number: "A-CASA-CASE-NUMBER-12345",
              text: "This text shall not be strikingly similar to other text in the document",
              org_address: nil,
              supervisor_name: nil,
              volunteer_case_assignment_date: 2.months.ago,
              volunteer_name: nil
            }
          end

          let(:casa_case) { create(:casa_case) }
          let(:contact_type) { create(:contact_type, name: document_data[:case_contact_type]) }
          let(:case_contact) { create(:case_contact, contact_made: false, occurred_at: document_data[:case_contact_time]) }
          let(:court_order) { create(:case_court_order, implementation_status: :partially_implemented) }
          let(:document_inspector) { DocxInspector.new(docx_contents: report.generate_to_string) }

          before(:each) do
            casa_case.casa_org.update_attribute(:address, document_data[:org_address])
            casa_case.update_attribute(:birth_month_year_youth, document_data[:case_birthday])
            casa_case.update_attribute(:case_number, document_data[:case_number])
            create(:court_date, casa_case: casa_case, date: document_data[:case_hearing_date])
            case_contact.contact_types << contact_type
            casa_case.case_contacts << case_contact
            casa_case.case_court_orders << court_order
            court_order.update_attribute(:text, document_data[:text])
          end

          it "displays today's date formatted" do
            expect(document_inspector.word_list_document_contains?(Date.today.strftime("%B %-d, %Y"))).to eq(true)
          end

          it "displays the case hearing date formatted" do
            expect(document_inspector.word_list_document_contains?(document_data[:case_hearing_date].strftime("%B %-d, %Y"))).to eq(true)
          end

          it "displays the case numbet" do
            expect(document_inspector.word_list_document_contains?(document_data[:case_number])).to eq(true)
          end

          it "displays the case contact type" do
            expect(document_inspector.word_list_document_contains?(document_data[:case_contact_type])).to eq(true)
          end

          it "displays the case contact time formatted" do
            expect(document_inspector.word_list_document_contains?("#{document_data[:case_contact_time].strftime("%-m/%d")}*")).to eq(true)
          end

          it "displays the test" do
            expect(document_inspector.word_list_document_contains?(document_data[:text])).to eq(true)
          end

          it "displays the order status" do
            expect(document_inspector.word_list_document_contains?("Partially implemented")).to eq(true) # Order Status
          end
        end
      end
    end

    describe "when receiving INVALID path_to_template" do
      let(:volunteer) { create(:volunteer, :with_cases_and_contacts, :with_assigned_supervisor) }
      let(:casa_case_with_contacts) { volunteer.casa_cases.first }
      let(:nonexistent_path) { "app/documents/templates/nonexisitent_report_template.docx" }

      it "will raise Zip::Error when generating report" do
        args = {
          case_id: casa_case_with_contacts.id,
          volunteer_id: volunteer.id,
          path_to_template: nonexistent_path
        }
        context = CaseCourtReportContext.new(args).context
        bad_report = CaseCourtReport.new(path_to_template: nonexistent_path, context: context)
        expect { bad_report.generate_to_string }.to raise_error(Zip::Error)
      end
    end

    describe "when court orders has different implementation statuses" do
      let(:casa_case) { create(:casa_case, case_number: "Sample-Case-12345") }
      let(:court_order_implemented) { create(:case_court_order, casa_case: casa_case, text: "K6N-ce8|NuXnht(", implementation_status: :implemented) }
      let(:court_order_unimplemented) { create(:case_court_order, casa_case: casa_case, text: "'q\"tE1LP-9W>,2)", implementation_status: :unimplemented) }
      let(:court_order_partially_implemented) { create(:case_court_order, casa_case: casa_case, text: "ZmCw@w@\d`&roct", implementation_status: :partially_implemented) }
      let(:court_order_not_specified) { create(:case_court_order, casa_case: casa_case, text: "(4WqOL7e'FRYd@%", implementation_status: nil) }
      let(:args) do
        {
          case_id: casa_case.id,
          path_to_template: path_to_template,
          path_to_report: path_to_report
        }
      end
      let(:context) { CaseCourtReportContext.new(args).context }
      let(:case_report) { CaseCourtReport.new(path_to_template: path_to_template, context: context) }
      let(:document_inspector) { DocxInspector.new(docx_contents: case_report.generate_to_string) }

      before(:each) do
        casa_case.case_court_orders << court_order_implemented
        casa_case.case_court_orders << court_order_unimplemented
        casa_case.case_court_orders << court_order_partially_implemented
        casa_case.case_court_orders << court_order_not_specified
      end

      it "contains the case number" do
        expect(document_inspector.word_list_document_contains?(casa_case.case_number)).to eq(true)
      end

      it "contains the court order text" do
        expect(document_inspector.word_list_document_contains?(court_order_implemented.text)).to eq(true)
      end

      it "contains the exact value of 'Implemented'" do
        expect(document_inspector.word_list_document_contains?("Implemented")).to eq(true)
      end

      it "contains the court order text" do
        expect(document_inspector.word_list_document_contains?(court_order_unimplemented.text)).to eq(true)
      end

      it "contains the exact value of 'Unimplemented'" do
        expect(document_inspector.word_list_document_contains?("Unimplemented")).to eq(true)
      end

      it "contains the court orde text" do
        expect(document_inspector.word_list_document_contains?(court_order_partially_implemented.text)).to eq(true)
      end

      it "contains the exact value of 'Partially implemented'" do
        expect(document_inspector.word_list_document_contains?("Partially implemented")).to eq(true)
      end

      it "contains the court order text" do
        expect(document_inspector.word_list_document_contains?(court_order_not_specified.text)).to eq(true)
      end

      it "contains the exact value of 'Not specified'" do
        expect(document_inspector.word_list_document_contains?("Not specified")).to eq(true)
      end
    end
  end
end

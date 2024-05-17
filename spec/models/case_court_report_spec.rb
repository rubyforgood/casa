# frozen_string_literal: true

require "rails_helper"
require "sablon"

RSpec.describe CaseCourtReport, type: :model do
  include DownloadHelpers
  let(:path_to_template) { Rails.root.join("app", "documents", "templates", "default_report_template.docx").to_s }
  let(:path_to_report) { Rails.root.join("tmp", "test_report.docx").to_s }

  context "#generate_to_string" do
    let(:full_context) do
      {
        created_date: "April 9, 2024",
        casa_case: {
          court_date: "April 23, 2024",
          case_number: "A-CASA-CASE-NUMBER-12345",
          dob: "April 2012",
          is_transitioning: false,
          judge_name: "Judge Judy"
        },
        case_contacts: [
          {name: "Some Name", type: "Type 1", dates: "4/09*", dates_by_medium_type: {"in-person" => "4/09*"}},
          {name: "Some Other Name", type: "Type 4", dates: "4/09*", dates_by_medium_type: {"in-person" => "4/09*"}}
        ],
        case_court_orders: [
          {order: "case_court_order_text", status: "Partially implemented"}
        ],
        case_mandates: [
          {order: "case_mandates_text", status: "Partially implemented"}
        ],
        latest_hearing_date: "___<LATEST HEARING DATE>____",
        org_address: "596 Unique Avenue Seattle, Washington",
        volunteer: {
          name: "name_of_volunteer",
          supervisor_name: "name_of_supervisor",
          assignment_date: "February 9, 2024"
        },
        hearing_type_name: "None",
        case_topics: [
          {topic: "Question 1", details: "Details 1", answers: [
            {date: "12/01/20", medium: "Type A1, Type B1", value: "Answer 1"},
            {date: "12/02/20", medium: "Type A2, Type B2", value: "Answer 3"}
          ]},
          {topic: "Question 2", details: "Details 2", answers: [
            {date: "12/01/20", medium: "Type A1, Type B1", value: "Answer 2"},
            {date: "12/02/20", medium: "Type A3, Type B3", value: "Answer 5"}
          ]},
          {topic: "Question 3", details: "Details 3", answers: [
            {date: "12/01/20", medium: "Type A3, Type B3", value: "No Answer Provided"},
            {date: "12/02/20", medium: "Type A2, Type B2", value: "No Answer Provided"}
          ]}
        ]
      }
    end
    describe "contact_topics" do
      it "all contact topics are present in the report" do
        docx_response = generate_doc(full_context, path_to_template)
        expect(docx_response.paragraphs.map(&:to_s)).to include(/Question 1.*/)
        expect(docx_response.paragraphs.map(&:to_s)).to include(/Question 2.*/)
        expect(docx_response.paragraphs.map(&:to_s)).to include(/Question 3.*/)
      end

      it "all topic details are present in the report" do
        docx_response = generate_doc(full_context, path_to_template)
        expect(docx_response.paragraphs.map(&:to_s)).to include(/Details 1.*/)
        expect(docx_response.paragraphs.map(&:to_s)).to include(/Details 2.*/)
        expect(docx_response.paragraphs.map(&:to_s)).to include(/Details 3.*/)
      end

      it "all answers are present with correct format" do
        docx_response = generate_doc(full_context, path_to_template)
        expect(docx_response.paragraphs.map(&:to_s)).to include(/Type A1, Type B1 \(12\/01\/20\): Answer 1.*/)
        expect(docx_response.paragraphs.map(&:to_s)).to include(/Type A2, Type B2 \(12\/02\/20\): Answer 3.*/)
        expect(docx_response.paragraphs.map(&:to_s)).to include(/Type A1, Type B1 \(12\/01\/20\): Answer 2.*/)
        expect(docx_response.paragraphs.map(&:to_s)).to include(/Type A3, Type B3 \(12\/02\/20\): Answer 5.*/)
        expect(docx_response.paragraphs.map(&:to_s)).to include(/Type A3, Type B3 \(12\/01\/20\): No Answer Provided.*/)
        expect(docx_response.paragraphs.map(&:to_s)).to include(/Type A2, Type B2 \(12\/02\/20\): No Answer Provided.*/)
      end

      context "when there are topics but no answers" do
        let(:curr_context) do
          full_context[:case_topics] = [
            {topic: "Question 1", details: "Details 1", answers: []},
            {topic: "Question 2", details: "Details 2", answers: []},
            {topic: "Question 3", details: "Details 3", answers: []}
          ]
        end

        it "all contact topics are present in the report" do
          docx_response = generate_doc(full_context, path_to_template)
          expect(docx_response.paragraphs.map(&:to_s)).to include(/Question 1.*/)
          expect(docx_response.paragraphs.map(&:to_s)).to include(/Question 2.*/)
          expect(docx_response.paragraphs.map(&:to_s)).to include(/Question 3.*/)
        end
        it "all topic details are present in the report" do
          docx_response = generate_doc(full_context, path_to_template)
          expect(docx_response.paragraphs.map(&:to_s)).to include(/Details 1.*/)
          expect(docx_response.paragraphs.map(&:to_s)).to include(/Details 2.*/)
          expect(docx_response.paragraphs.map(&:to_s)).to include(/Details 3.*/)
        end
      end

      context "when there no topics" do
        it "report does not error and puts old defaults" do
          full_context[:case_topics] = []
          docx_response = nil
          expect {
            docx_response = generate_doc(full_context, path_to_template)
          }.not_to raise_error

          expect(docx_response).not_to be_nil
          expect(docx_response.paragraphs.map(&:to_s)).to include(/Placement.*/)
          expect(docx_response.paragraphs.map(&:to_s)).to include(/Education\/Vocation.*/)
          expect(docx_response.paragraphs.map(&:to_s)).to include(/Objective Information.*/)
        end
      end
    end

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
            docx_response = Docx::Document.open(StringIO.new(report.generate_to_string))
            expect(header_text(docx_response)).to include(document_data[:org_address])
          end

          it "displays today's date formatted" do
            docx_response = Docx::Document.open(StringIO.new(report.generate_to_string))
            expect(docx_response.paragraphs.map(&:to_s)).to include(/#{Date.current.strftime("%B %-d, %Y")}.*/)
          end

          it "displays the case hearing date date formatted" do
            docx_response = Docx::Document.open(StringIO.new(report.generate_to_string))
            expect(docx_response.paragraphs.map(&:to_s)).to include(/#{document_data[:case_hearing_date].strftime("%B %-d, %Y")}.*/)
          end

          it "displays the case number" do
            docx_response = Docx::Document.open(StringIO.new(report.generate_to_string))
            expect(docx_response.paragraphs.map(&:to_s)).to include(/#{document_data[:case_number]}.*/)
          end

          it "displays the case contact type" do
            docx_response = Docx::Document.open(StringIO.new(report.generate_to_string))

            table_data = docx_response.tables.map { |t| t.rows.map(&:cells).flatten.map(&:to_s) }.flatten

            expect(table_data).to include(/#{document_data[:case_contact_type]}.*/)
          end

          it "displays the case contact time date formatted" do
            docx_response = Docx::Document.open(StringIO.new(report.generate_to_string))

            table_data = docx_response.tables.map { |t| t.rows.map(&:cells).flatten.map(&:to_s) }.flatten

            expect(table_data).to include(/#{document_data[:case_contact_time].strftime("%-m/%d")}.*/)
          end

          it "displays the text" do
            docx_response = Docx::Document.open(StringIO.new(report.generate_to_string))

            table_data = docx_response.tables.map { |t| t.rows.map(&:cells).flatten.map(&:to_s) }.flatten

            expect(table_data).to include(/#{document_data[:text]}.*/)
          end

          it "displays the order status" do
            docx_response = Docx::Document.open(StringIO.new(report.generate_to_string))

            table_data = docx_response.tables.map { |t| t.rows.map(&:cells).flatten.map(&:to_s) }.flatten

            expect(table_data).to include("Partially implemented")
          end

          it "displays the volunteer name" do
            docx_response = Docx::Document.open(StringIO.new(report.generate_to_string))

            table_data = docx_response.tables.map { |t| t.rows.map(&:cells).flatten.map(&:to_s) }.flatten

            expect(table_data).to include(/#{document_data[:volunteer_name]}.*/)
          end

          it "displays the volunteer case assignment date formatted" do
            docx_response = Docx::Document.open(StringIO.new(report.generate_to_string))

            table_data = docx_response.tables.map { |t| t.rows.map(&:cells).flatten.map(&:to_s) }.flatten

            expect(table_data).to include(/#{document_data[:volunteer_case_assignment_date].strftime("%B %-d, %Y")}.*/)
          end

          it "displayes the supervisor name" do
            docx_response = Docx::Document.open(StringIO.new(report.generate_to_string))

            table_data = docx_response.tables.map { |t| t.rows.map(&:cells).flatten.map(&:to_s) }.flatten

            expect(table_data).to include(/#{document_data[:supervisor_name]}.*/)
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
            docx_response = Docx::Document.open(StringIO.new(report.generate_to_string))

            expect(docx_response.paragraphs.map(&:to_s)).to include(/#{Date.current.strftime("%B %-d, %Y")}.*/)
          end

          it "displays the case hearing date formatted" do
            docx_response = Docx::Document.open(StringIO.new(report.generate_to_string))

            expect(docx_response.paragraphs.map(&:to_s)).to include(/#{document_data[:case_hearing_date].strftime("%B %-d, %Y")}.*/)
          end

          it "displays the case number" do
            docx_response = Docx::Document.open(StringIO.new(report.generate_to_string))
            expect(docx_response.paragraphs.map(&:to_s)).to include(/.*#{document_data[:case_number]}.*/)
          end

          it "displays the case contact type" do
            docx_response = Docx::Document.open(StringIO.new(report.generate_to_string))

            table_data = docx_response.tables.map { |t| t.rows.map(&:cells).flatten.map(&:to_s) }.flatten

            expect(table_data).to include(document_data[:case_contact_type])
          end

          it "displays the case contact time formatted" do
            docx_response = Docx::Document.open(StringIO.new(report.generate_to_string))

            table_data = docx_response.tables.map { |t| t.rows.map(&:cells).flatten.map(&:to_s) }.flatten

            expect(table_data).to include(document_data[:case_contact_time].strftime("%-m/%d*"))
          end

          it "displays the test" do
            docx_response = Docx::Document.open(StringIO.new(report.generate_to_string))

            table_data = docx_response.tables.map { |t| t.rows.map(&:cells).flatten.map(&:to_s) }.flatten

            expect(table_data).to include("This text shall not be strikingly similar to other text in the document")
          end

          it "displays the order status" do
            docx_response = Docx::Document.open(StringIO.new(report.generate_to_string))

            table_data = docx_response.tables.map { |t| t.rows.map(&:cells).flatten.map(&:to_s) }.flatten

            expect(table_data).to include("Partially implemented")
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
      let(:court_order_implemented) { create(:case_court_order, casa_case: casa_case, text: "an order that got done", implementation_status: :implemented) }
      let(:court_order_unimplemented) { create(:case_court_order, casa_case: casa_case, text: "an order that got not done", implementation_status: :unimplemented) }
      let(:court_order_partially_implemented) { create(:case_court_order, casa_case: casa_case, text: "an order that got kinda done", implementation_status: :partially_implemented) }
      let(:court_order_not_specified) { create(:case_court_order, casa_case: casa_case, text: "what is going on", implementation_status: nil) }
      let(:args) do
        {
          case_id: casa_case.id,
          path_to_template: path_to_template,
          path_to_report: path_to_report
        }
      end
      let(:context) { CaseCourtReportContext.new(args).context }
      let(:case_report) { CaseCourtReport.new(path_to_template: path_to_template, context: context) }

      before(:each) do
        casa_case.case_court_orders << court_order_implemented
        casa_case.case_court_orders << court_order_unimplemented
        casa_case.case_court_orders << court_order_partially_implemented
        casa_case.case_court_orders << court_order_not_specified
      end

      it "contains the case number" do
        docx_response = Docx::Document.open(StringIO.new(case_report.generate_to_string))

        expect(docx_response.paragraphs.map(&:to_s)).to include(/#{casa_case.case_number}*/)
      end

      it "contains the court order text" do
        docx_response = Docx::Document.open(StringIO.new(case_report.generate_to_string))

        expect(table_text(docx_response)).to include(/#{court_order_implemented.text}.*/)
      end

      it "contains the exact value of 'Implemented'" do
        docx_response = Docx::Document.open(StringIO.new(case_report.generate_to_string))

        expect(table_text(docx_response)).to include(/Implemented.*/)
      end

      it "contains the court order text" do
        docx_response = Docx::Document.open(StringIO.new(case_report.generate_to_string))

        expect(table_text(docx_response)).to include(/#{court_order_unimplemented.text}.*/)
      end

      it "contains the exact value of 'Unimplemented'" do
        docx_response = Docx::Document.open(StringIO.new(case_report.generate_to_string))

        expect(table_text(docx_response)).to include(/Unimplemented.*/)
      end

      it "contains the court order text" do
        docx_response = Docx::Document.open(StringIO.new(case_report.generate_to_string))

        expect(table_text(docx_response)).to include(/#{court_order_partially_implemented.text}.*/)
      end

      it "contains the exact value of 'Partially implemented'" do
        docx_response = Docx::Document.open(StringIO.new(case_report.generate_to_string))

        expect(table_text(docx_response)).to include(/Partially implemented.*/)
      end

      it "contains the court order text" do
        docx_response = Docx::Document.open(StringIO.new(case_report.generate_to_string))

        expect(table_text(docx_response)).to include(/#{court_order_not_specified.text}.*/)
      end

      it "contains the exact value of 'Not specified'" do
        docx_response = Docx::Document.open(StringIO.new(case_report.generate_to_string))

        expect(table_text(docx_response)).to include(/Not specified.*/)
      end
    end
  end
end

def generate_doc(context, path_to_template)
  report = CaseCourtReport.new(path_to_template: path_to_template, context: context)
  Docx::Document.open(StringIO.new(report.generate_to_string))
end

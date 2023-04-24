# frozen_string_literal: true

require "rails_helper"
require "sablon"

RSpec.describe CaseCourtReportContext, type: :model do
  let(:volunteer) { create(:volunteer, :with_casa_cases) }
  let(:path_to_template) { Rails.root.join("app", "documents", "templates", "default_report_template.docx").to_s }
  let(:path_to_report) { Rails.root.join("tmp", "test_report.docx").to_s }

  before do
    travel_to Date.new(2021, 1, 1)
  end

  describe "#context" do
    let(:court_report_context) { build(:case_court_report_context) }

    describe ":created_date" do
      it "has a created date equal to the current date" do
        expect(court_report_context.context[:created_date]).to eq("January 1, 2021")
      end
    end

    describe ":casa_case" do
      let(:case_number) { "Sample-Case-12345" }
      let(:casa_case) {
        create(:casa_case,
          birth_month_year_youth: 121.months.ago, # 10 Years 1 month ago
          case_number: case_number)
      }
      let(:court_report_context) { build(:case_court_report_context, casa_case: casa_case) }

      describe ":court_date" do
        context "when there are future court dates" do
          let(:court_date_1) { create(:court_date, date: 2.months.since) }
          let(:court_date_2) { create(:court_date, date: 5.months.since) }

          before(:each) do
            casa_case.court_dates << court_date_1
            casa_case.court_dates << court_date_2
          end

          it "contains the soonest future court date in a human readable format" do
            expect(court_report_context.context[:casa_case][:court_date]).to eq("March 1, 2021")
          end
        end

        context "when there are no future court dates" do
          let(:past_court_date) { create(:court_date, date: 2.months.ago) }

          before(:each) do
            casa_case.court_dates << past_court_date
          end

          it "contains the soonest future court date in a human readable format" do
            expect(court_report_context.context[:casa_case][:court_date]).to be_nil
          end
        end
      end

      describe ":case_number" do
        it "contains the case number of the casa case" do
          expect(court_report_context.context[:casa_case][:case_number]).to eq(case_number)
        end
      end

      describe ":dob" do
        it "contains the month and year of birth" do
          expect(court_report_context.context[:casa_case][:dob]).to eq("December 2010")
        end
      end

      describe ":is_transitioning" do
        context "when the case birth month and year is less than 14 years ago" do
          before(:each) do
            casa_case.update_attribute(:birth_month_year_youth, 167.months.ago)
          end

          it "contains false" do
            expect(court_report_context.context[:casa_case][:is_transitioning]).to eq(false)
          end
        end

        context "when the case birth month and year is greater or equal to 14 years ago" do
          before(:each) do
            casa_case.update_attribute(:birth_month_year_youth, 14.years.ago)
          end

          it "contains true" do
            expect(court_report_context.context[:casa_case][:is_transitioning]).to eq(true)
          end
        end
      end

      describe ":judge_name" do
        context "when there are future court dates" do
          let(:next_court_date_judge_name) { "Judge A" }
          let(:court_date_1) { create(:court_date, :with_judge, date: 2.months.since) }
          let(:court_date_2) { create(:court_date, :with_judge, date: 5.months.since) }

          before(:each) do
            court_date_1.judge.update_attribute(:name, next_court_date_judge_name)
            court_date_2.judge.update_attribute(:name, "Judge B")

            casa_case.court_dates << court_date_1
            casa_case.court_dates << court_date_2
          end

          it "contains the soonest future court date in a human readable format" do
            expect(court_report_context.context[:casa_case][:judge_name]).to eq(next_court_date_judge_name)
          end
        end
      end
    end

    describe ":case_contacts" do
    end

    describe ":case_court_orders and :case_mandates" do
      let(:casa_case) { create(:casa_case, case_number: "Sample-Case-12345") }
      let!(:court_order_implemented) { create(:case_court_order, text: "K6N-ce8|NuXnht(", implementation_status: :implemented) }
      let!(:court_order_unimplemented) { create(:case_court_order, text: "'q\"tE1LP-9W>,2)", implementation_status: :unimplemented) }
      let!(:court_order_partially_implemented) { create(:case_court_order, text: "ZmCw@w@\d`&roct", implementation_status: :partially_implemented) }
      let!(:court_order_not_specified) { create(:case_court_order, text: "(4WqOL7e'FRYd@%", implementation_status: nil) }
      let(:court_report_context) { build(:case_court_report_context, casa_case: casa_case).context }

      before(:each) do
        casa_case.case_court_orders << court_order_implemented
        casa_case.case_court_orders << court_order_not_specified
        casa_case.case_court_orders << court_order_partially_implemented
        casa_case.case_court_orders << court_order_unimplemented
      end

      it "has a list of court orders the same length as all the court orders in the case" do
        expect(court_report_context[:case_court_orders].length).to eq(casa_case.case_court_orders.length)
      end

      it "includes the implementation status and text of each court order" do
        expect(court_report_context[:case_court_orders]).to include({order: court_order_implemented.text, status: court_order_implemented.implementation_status&.humanize})
        expect(court_report_context[:case_court_orders]).to include({order: court_order_not_specified.text, status: court_order_not_specified.implementation_status&.humanize})
        expect(court_report_context[:case_court_orders]).to include({order: court_order_partially_implemented.text, status: court_order_partially_implemented.implementation_status&.humanize})
        expect(court_report_context[:case_court_orders]).to include({order: court_order_unimplemented.text, status: court_order_unimplemented.implementation_status&.humanize})
      end

      it "has identical values for :case_court_orders and :case_mandates" do
        expect(court_report_context[:case_mandates]).to eq(court_report_context[:case_court_orders]) # backwards compatibility for old names in old montgomery template - TODO track it down and update prod templates
      end
    end

    describe ":latest_hearing_date" do
      context "when there are no hearing dates" do
        it "contains text prompting the reader to enter a hearing date" do
          expect(court_report_context.context[:latest_hearing_date]).to eq("___<LATEST HEARING DATE>____")
        end
      end

      context "when there are multiple hearing dates" do
        let(:casa_case_with_court_dates) {
          casa_case = create(:casa_case)

          casa_case.court_dates << create(:court_date, date: 9.months.ago)
          casa_case.court_dates << create(:court_date, date: 3.months.ago)
          casa_case.court_dates << create(:court_date, date: 15.months.ago)

          casa_case
        }

        let(:court_report_context_with_latest_hearing_date) { build(:case_court_report_context, casa_case: casa_case_with_court_dates) }

        it "sets latest_hearing_date as the latest past court date" do
          expect(court_report_context_with_latest_hearing_date.context[:latest_hearing_date]).to eq("October 1, 2020")
        end
      end
    end

    describe ":org_address" do
      let(:casa_org_address) { "-m}~2c<Lk/te{<\"" }
      let(:case_court_report_context_with_org_address) {
        volunteer = create(:volunteer)

        volunteer.casa_org.update_attribute(:address, casa_org_address)

        build(:case_court_report_context, volunteer: volunteer)
      }

      context "when the casa org has an address" do
        it "appears in the context under the org_address key" do
          expect(case_court_report_context_with_org_address.context[:org_address]).to eq(casa_org_address)
        end
      end
    end

    describe ":volunteer" do
      describe ":assignment_date" do
      end
      describe ":name" do
      end
      describe ":supervisor_name" do
      end
    end

    describe "when receiving valid case, volunteer, and path_to_template" do
      let(:volunteer) { create(:volunteer, :with_cases_and_contacts, :with_assigned_supervisor) }
      let(:casa_case_with_contacts) { volunteer.casa_cases.first }
      let(:casa_case_without_contacts) { volunteer.casa_cases.second }

      subject do
        described_class.new(
          case_id: casa_case_with_contacts.id,
          volunteer_id: volunteer.id,
          path_to_template: path_to_template,
          path_to_report: path_to_report
        ).context
      end

      describe "with volunteer without supervisor" do
        let(:volunteer) { create(:volunteer, :with_cases_and_contacts) }

        it "has supervisor name placeholder" do
          expect(subject[:volunteer][:supervisor_name]).to eq("")
        end
      end

      describe "with court date in the future" do
        let!(:far_past_case_contact) { create :case_contact, occurred_at: 5.days.ago, casa_case_id: casa_case_with_contacts.id }

        before do
          create(:court_date, casa_case: casa_case_with_contacts, date: 1.day.from_now)
        end

        describe "without past court date" do
          it "has all case contacts ever created for the youth" do
            expect(subject[:case_contacts].length).to eq(5)
          end
        end

        describe "with past court date" do
          let!(:court_date) { create(:court_date, date: 2.days.ago, casa_case_id: casa_case_with_contacts.id) }

          it "has all case contacts created since the previous court date including case contact created on the court date" do
            create(:case_contact, casa_case: casa_case_with_contacts, created_at: court_date.date, notes: "created ON most recent court date")
            expect(casa_case_with_contacts.court_dates.length).to eq(2)
            expect(subject[:case_contacts].length).to eq(5)
          end
        end
      end
    end
  end
end

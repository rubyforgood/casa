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

        context "when they specify a specific court date they are interested in looking at" do
          it "contains the selected court date in a human readable format" do
            court_date_1 = create(:court_date, date: 2.months.since)
            court_date_2 = create(:court_date, date: 5.months.since)

            casa_case.court_dates << court_date_1
            casa_case.court_dates << court_date_2

            court_report_context = build(:case_court_report_context, casa_case: casa_case, court_date: court_date_2)
            expect(court_report_context.context[:casa_case][:court_date]).to eq("June 1, 2021")
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
      let(:casa_case) { create(:casa_case) }
      let(:case_contact_1_date) { 30.days.ago }
      let(:case_contact_2_date) { 45.days.ago }
      let(:case_contact_3_date) { 60.days.ago }
      let(:case_contact_4_date) { 75.days.ago }
      let(:case_contact_1) { build(:case_contact, occurred_at: case_contact_1_date) }
      let(:case_contact_2) { build(:case_contact, occurred_at: case_contact_2_date) }
      let(:case_contact_3) { build(:case_contact, occurred_at: case_contact_3_date) }
      let(:case_contact_4) { build(:case_contact, occurred_at: case_contact_4_date) }
      let(:contact_type_1) { build(:contact_type, name: "XM_L!_g=Ko\\-'A!") }
      let(:contact_type_2) { build(:contact_type, name: "uHp$O2;oq!C3{]l") }
      let(:contact_type_3) { build(:contact_type, name: "\"PlqEsCP[JktjTS") }
      let(:contact_type_4) { build(:contact_type, name: "K3BbzNCni4mVC5@") }
      let(:contact_type_5) { build(:contact_type, name: "lf7CA&n8BQ*qJ?E") }
      let(:court_report_context) { build(:case_court_report_context, casa_case: casa_case).context }

      before(:each) do
        case_contact_1.contact_types << contact_type_1
        case_contact_2.contact_types << contact_type_2
        case_contact_3.contact_types << contact_type_3
        case_contact_4.contact_types << contact_type_4
        case_contact_1.contact_types << contact_type_5

        casa_case.case_contacts << case_contact_1
        casa_case.case_contacts << case_contact_2
        casa_case.case_contacts << case_contact_3
        casa_case.case_contacts << case_contact_4
      end

      it "for each contact type in a case contact, contains the name of the type and the occurred at date" do
        expect(court_report_context[:case_contacts]).to include(include(dates: case_contact_1_date.strftime("%m/%d*"), type: contact_type_1.name))
        expect(court_report_context[:case_contacts]).to include(include(dates: case_contact_2_date.strftime("%m/%d*"), type: contact_type_2.name))
        expect(court_report_context[:case_contacts]).to include(include(dates: case_contact_3_date.strftime("%m/%d*"), type: contact_type_3.name))
        expect(court_report_context[:case_contacts]).to include(include(dates: case_contact_4_date.strftime("%m/%d*"), type: contact_type_4.name))
        expect(court_report_context[:case_contacts]).to include(include(dates: case_contact_1_date.strftime("%m/%d*"), type: contact_type_5.name))
      end

      it "for each contact type in a case contact, contains a placeholder value for the name(s) of the people involved" do
        case_contact_report_data = court_report_context[:case_contacts]
        expect(case_contact_report_data.length).to be > 0

        case_contact_report_data.each { |contact_type_and_dates|
          expect(contact_type_and_dates[:name]).to eq("Names of persons involved, starting with the child's name")
        }
      end

      context "when a contact type is included in multiple case contacts" do
        before(:each) do
          case_contact_2.contact_types << contact_type_1
          case_contact_4.contact_types << contact_type_1
        end

        it "includes an object with the contact type name and the dates of all case contacts" do
          contact_type_and_dates = court_report_context[:case_contacts].find { |case_contact_type_and_dates|
            case_contact_type_and_dates[:type] == contact_type_1.name
          }

          expect(contact_type_and_dates).to_not be_nil
          expect(contact_type_and_dates[:dates]).to include(case_contact_1_date.strftime("%m/%d"))
          expect(contact_type_and_dates[:dates]).to include(case_contact_2_date.strftime("%m/%d"))
          expect(contact_type_and_dates[:dates]).to include(case_contact_4_date.strftime("%m/%d"))
          expect(contact_type_and_dates[:dates]).to_not include(case_contact_3_date.strftime("%m/%d"))
        end

        it "contains a string with the dates of the case contacts with the contact type sorted by oldest date first" do
          contact_type_and_dates = court_report_context[:case_contacts].find { |case_contact_type_and_dates|
            case_contact_type_and_dates[:type] == contact_type_1.name
          }

          expect(contact_type_and_dates).to_not be_nil

          dates = contact_type_and_dates[:dates]
          case_contact_1_date_index = dates.index(case_contact_1_date.strftime("%m/%d"))
          case_contact_2_date_index = dates.index(case_contact_2_date.strftime("%m/%d"))
          case_contact_4_date_index = dates.index(case_contact_4_date.strftime("%m/%d"))

          expect(case_contact_1_date_index).to be > case_contact_2_date_index
          expect(case_contact_2_date_index).to be > case_contact_4_date_index
        end

        context "when there are multiple medium types" do
          before(:each) do
            case_contact_4.update_attribute(:medium_type, "voice-only")
          end

          describe ":dates_by_medium_type" do
            it "contains a key for each medium type and the dates of the case contacts with the medium type the values" do
              case_contact_object_containing_complex_dates_by_medium_type = court_report_context[:case_contacts].find { |case_contact_type_and_dates|
                case_contact_type_and_dates[:type] == contact_type_1.name
              }

              dates_by_medium_type = case_contact_object_containing_complex_dates_by_medium_type[:dates_by_medium_type]

              expect(dates_by_medium_type).to have_key(case_contact_1.medium_type)
              expect(dates_by_medium_type).to have_key(case_contact_4.medium_type)

              expect(dates_by_medium_type[case_contact_1.medium_type]).to include(case_contact_1_date.strftime("%m/%d"))
              expect(dates_by_medium_type[case_contact_2.medium_type]).to include(case_contact_2_date.strftime("%m/%d"))
              expect(dates_by_medium_type[case_contact_4.medium_type]).to include(case_contact_4_date.strftime("%m/%d"))
            end
          end
        end
      end

      context "when there are past court dates" do
        let!(:past_court_date) { create(:court_date, date: 50.days.ago, casa_case: casa_case) }

        it "contains only case contacts information after the latest past court date" do
          expect(court_report_context[:case_contacts]).to include(include(type: contact_type_1.name))
          expect(court_report_context[:case_contacts]).to include(include(type: contact_type_5.name))
          expect(court_report_context[:case_contacts]).to include(include(type: contact_type_2.name))
          expect(court_report_context[:case_contacts]).to_not include(include(type: contact_type_3.name))
          expect(court_report_context[:case_contacts]).to_not include(include(type: contact_type_4.name))
        end
      end
    end

    describe ":case_court_orders and :case_mandates" do
      let(:casa_case) { create(:casa_case, case_number: "Sample-Case-12345") }
      let!(:court_order_implemented) { build(:case_court_order, text: "K6N-ce8|NuXnht(", implementation_status: :implemented) }
      let!(:court_order_unimplemented) { build(:case_court_order, text: "'q\"tE1LP-9W>,2)", implementation_status: :unimplemented) }
      let!(:court_order_partially_implemented) { build(:case_court_order, text: "ZmCw@w@\d`&roct", implementation_status: :partially_implemented) }
      let!(:court_order_not_specified) { build(:case_court_order, text: "(4WqOL7e'FRYd@%", implementation_status: nil) }
      let(:court_report_context) { build(:case_court_report_context, casa_case: casa_case).context }

      before(:each) do
        casa_case.case_court_orders << court_order_implemented
        casa_case.case_court_orders << court_order_not_specified
        casa_case.case_court_orders << court_order_partially_implemented

        casa_case.case_court_orders << court_order_unimplemented
      end

      context "when using specified orders to a specific casa date" do
        it "does not lean on orders of the casa case if specified directly" do
          court_order = build(:case_court_order, text: "Some Court Text", implementation_status: :implemented)
          court_report_context = build(:case_court_report_context, casa_case: casa_case, case_court_orders: [court_order]).context
          expect(court_report_context[:case_court_orders]).to eq([{order: "Some Court Text", status: "Implemented"}])
        end
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

          casa_case.court_dates << build(:court_date, date: 9.months.ago)
          casa_case.court_dates << build(:court_date, date: 3.months.ago)
          casa_case.court_dates << build(:court_date, date: 15.months.ago)

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
      let(:volunteer) { create(:volunteer, display_name: "Y>cy%F7v;\\].-g$", supervisor: build(:supervisor, display_name: "Mm^ED;`zg(g<Z]q")) }
      let(:case_court_report_context) { build(:case_court_report_context, volunteer: volunteer) }

      describe ":assignment_date" do
        it "contains the assignment date in a human readable format" do
          case_court_report_context.instance_variable_get(:@casa_case).case_assignments.first.update_attribute(:created_at, 24.months.ago)

          expect(case_court_report_context.context[:volunteer][:assignment_date]).to eq("January 1, 2019")
        end
      end

      describe ":name" do
        it "contains the volunteer's name" do
          expect(case_court_report_context.context[:volunteer][:name]).to eq(volunteer.display_name)
        end
      end

      describe ":supervisor_name" do
        it "contains the name of the volunteer's supervisor" do
          expect(case_court_report_context.context[:volunteer][:supervisor_name]).to eq(volunteer.supervisor.display_name)
        end
      end
    end
  end
end

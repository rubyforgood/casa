# frozen_string_literal: true

require "rails_helper"

RSpec.describe CaseContactsExportCsvService, type: :service do
  describe "#perform" do
    it "exports the case contacts without the court topics header by default" do
      casa_case = create(:casa_case)
      create(:case_contact, casa_case: casa_case, medium_type: "text/email", occurred_at: Date.new(2026, 1, 8))
      case_contacts = casa_case.decorate.case_contacts_ordered_by_occurred_at

      csv = CaseContactsExportCsvService.new(case_contacts, filtered_columns).perform

      parsed_csv = CSV.parse(csv, headers: true)
      expect(parsed_csv.count).to eq(1)
      expect(parsed_csv.headers).to eq(expected_headers)
      expect(csv).to match(%r{text/email})
      expect(csv).to match(/January 8, 2026/)
      expect(parsed_csv.headers).not_to include("Court Topics")
    end

    context "when there are no case contacts" do
      it "exports only the headers" do
        casa_case = build(:casa_case)
        case_contacts = casa_case.decorate.case_contacts_ordered_by_occurred_at

        csv = CaseContactsExportCsvService.new(case_contacts, filtered_columns).perform

        parsed_csv = CSV.parse(csv, headers: true)
        expect(parsed_csv.count).to eq(0)
        expect(parsed_csv.headers).to eq(expected_headers)
      end
    end

    context "when the filtered columns includes court topics" do
      it "exports the case contacts with the CaseContactReport::COLUMNS with the contact topics" do
        casa_case = create(:casa_case)
        case_contact = build(:case_contact, casa_case:, medium_type: "text/email", occurred_at: Date.new(2026, 1, 8))
        create(:case_contact, casa_case:, medium_type: "in-person", occurred_at: Date.new(2026, 3, 16))
        contact_topic = build(:contact_topic, question: "A Topic")
        create(:contact_topic_answer, case_contact:, contact_topic:, value: "An answer")
        case_contacts = casa_case.decorate.case_contacts_ordered_by_occurred_at

        csv = CaseContactsExportCsvService.new(case_contacts, filtered_columns).perform

        parsed_csv = CSV.parse(csv, headers: true)
        expect(parsed_csv.count).to eq(2)
        expect(parsed_csv.headers).to eq(expected_headers + ["A Topic"])
        expect(csv).to match(/in-person/)
        expect(csv).to match(/March 16, 2026/)
        expect(csv).to match(%r{text/email})
        expect(csv).to match(/January 8, 2026/)
        expect(csv).to match(/a topic/i)
        expect(csv).to match(/an answer/i)
      end

      it "does not include topics that don't have any answers" do
        casa_case = create(:casa_case)
        case_contact = build(:case_contact, casa_case: casa_case, medium_type: "text/email", occurred_at: Date.new(2026, 1, 8))
        contact_topic = build(:contact_topic, question: "A Topic with an Answer")
        create(:contact_topic_answer, contact_topic:, case_contact:, value: "An answer")
        build(:contact_topic, question: "Nothing to show")
        case_contacts = casa_case.decorate.case_contacts_ordered_by_occurred_at

        csv = CaseContactsExportCsvService.new(case_contacts, filtered_columns).perform

        parsed_csv = CSV.parse(csv, headers: true)
        expect(parsed_csv.count).to eq(1)
        expect(parsed_csv.headers).to eq(expected_headers + ["A Topic with an Answer"])
        expect(csv).to match(%r{text/email})
        expect(csv).to match(/January 8, 2026/)
        expect(csv).to include("An answer")
        expect(csv).not_to include("Nothing to show")
      end

      context "when there are multiple answers to a case contact's court topic" do
        it "exports the case contact including only the latest contact topic answer" do
          casa_case = create(:casa_case)
          case_contact = build(:case_contact, casa_case: casa_case, medium_type: "text/email", occurred_at: Date.new(2026, 1, 8))
          contact_topic = build(:contact_topic, question: "A Topic")
          create(:contact_topic_answer, case_contact:, contact_topic:, value: "First answer")
          create(:contact_topic_answer, case_contact:, contact_topic:, value: "Second answer")
          case_contacts = casa_case.decorate.case_contacts_ordered_by_occurred_at

          csv = CaseContactsExportCsvService.new(case_contacts, filtered_columns).perform

          parsed_csv = CSV.parse(csv, headers: true)
          expect(parsed_csv.count).to eq(1)
          expect(parsed_csv.headers).to eq(expected_headers + ["A Topic"])
          expect(csv).to match(%r{text/email})
          expect(csv).to match(/January 8, 2026/)
          expect(csv).to match(/a topic/i)
          expect(csv).to include("Second answer")
          expect(csv).not_to include("First answer")
        end
      end
    end

    context "when court topics are filtered out" do
      it "exports the case contacts with the CaseContactReport::COLUMNS without the Court topics entries" do
        casa_case = create(:casa_case)
        case_contact = build(:case_contact, casa_case:, medium_type: "text/email", occurred_at: Date.new(2026, 1, 8))
        create(:case_contact, casa_case:, medium_type: "in-person", occurred_at: Date.new(2026, 3, 16))
        contact_topic = build(:contact_topic, question: "Another Topic")
        create(:contact_topic_answer, case_contact:, contact_topic:, value: "Another answer")
        case_contacts = casa_case.decorate.case_contacts_ordered_by_occurred_at
        filtered_columns = CaseContactReport::COLUMNS - [:court_topics]

        csv = CaseContactsExportCsvService.new(case_contacts, filtered_columns).perform

        parsed_csv = CSV.parse(csv, headers: true)
        expect(parsed_csv.count).to eq(2)
        expect(parsed_csv.headers).to eq(expected_headers - ["A Topic"])
        expect(csv).to match(/in-person/)
        expect(csv).to match(/March 16, 2026/)
        expect(csv).to match(%r{text/email})
        expect(csv).to match(/January 8, 2026/)
        expect(csv).not_to include("Another Topic")
        expect(csv).not_to include("Another answer")
      end
    end
  end

  def filtered_columns
    CaseContactReport::COLUMNS
  end

  def expected_headers
    [
      "Internal Contact Number",
      "Duration Minutes",
      "Contact Types",
      "Contact Made",
      "Contact Medium",
      "Occurred At",
      "Added To System At",
      "Miles Driven",
      "Wants Driving Reimbursement",
      "Casa Case Number",
      "Creator Email",
      "Creator Name",
      "Supervisor Name",
      "Case Contact Notes"
    ]
  end
end

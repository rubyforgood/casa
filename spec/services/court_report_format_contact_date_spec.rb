# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourtReportFormatContactDate, type: :service do
  describe "#format" do
    context "when there has been a successful contact" do
      it "returns the day and month of when the Case Contact's occcurred" do
        case_contact = build(
          :case_contact,
          occurred_at: Date.new(2026, 4, 16),
          contact_made: true
        )

        contact_date = CourtReportFormatContactDate.new(case_contact).format

        expect(contact_date).to eq("4/16")
      end
    end

    context "when there has been no contact made" do
      it "returns the day and month of when the Case Contact's occcurred with a suffix" do
        case_contact = build(:case_contact, occurred_at: Date.new(2026, 3, 16))

        contact_date = CourtReportFormatContactDate.new(case_contact).format

        expect(contact_date).to eq("3/16*")
      end
    end
  end

  describe "#format_long" do
    it "returns the day, month and year of when the Case Contact's in the long format" do
      case_contact = build(:case_contact, occurred_at: Date.new(2026, 2, 16))

      contact_date = CourtReportFormatContactDate.new(case_contact).format_long

      expect(contact_date).to eq("02/16/26")
    end
  end
end

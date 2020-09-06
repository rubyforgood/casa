require "rails_helper"
require "csv"
RSpec.describe CaseContactReport, type: :model do
  describe "#generate_headers" do
    it "matches the length of row data" do
      create(:case_contact)
      csv = described_class.new.to_csv
      parsed_csv = CSV.parse(csv)

      expect(parsed_csv.length).to eq(2)
      expect(parsed_csv[0].length).to eq(parsed_csv[1].length)
      expect(parsed_csv[0]).to eq([
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
      ])
      case_contact_data = parsed_csv[1]
      expect(case_contact_data[1]).to eq("60")
    end
  end
  describe "filter behavior" do
    describe "occured at range filter" do
      
      it "uses date range if provided" do
        create(:case_contact, {occurred_at: 20.days.ago})
        create(:case_contact, {occurred_at: 100.days.ago})
        report = CaseContactReport.new({start_date: 30.days.ago, end_date: 10.days.ago})
        contacts = report.case_contacts
        expect(contacts.length).to eq(1)
      end
      it "returns all date ranges if not provided" do
        create(:case_contact, {occurred_at: 20.days.ago})
        create(:case_contact, {occurred_at: 100.days.ago})
        report = CaseContactReport.new({})
        contacts = report.case_contacts
        expect(contacts.length).to eq(2)
      end
      it "returns only the volunteer" do
        volunteer = create(:volunteer)
        create(:case_contact, {occurred_at: 20.days.ago, creator_id: volunteer.id})
        create(:case_contact, {occurred_at: 100.days.ago})
        report = CaseContactReport.new({creator_id: volunteer.id})
        contacts = report.case_contacts
        expect(contacts.length).to eq(1)
      end
      it "returns only the volunteer with date range" do
        volunteer = create(:volunteer)
        create(:case_contact, {occurred_at: 20.days.ago, creator_id: volunteer.id})
        create(:case_contact, {occurred_at: 100.days.ago, creator_id: volunteer.id})
       
        create(:case_contact, {occurred_at: 100.days.ago})
        report = CaseContactReport.new({start_date: 30.days.ago, end_date: 10.days.ago, creator_id: volunteer.id})
        contacts = report.case_contacts
        expect(contacts.length).to eq(1)
      end
    end
  end
end

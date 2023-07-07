require "rails_helper"
require "csv"

RSpec.describe MileageReport, type: :model do
  describe "#to_csv" do
    it "includes only case contacts that are eligible for driving reimbursement and not already reimbursed" do
      user1 = create(:volunteer, display_name: "Linda")
      contact_type1 = create(:contact_type, name: "Therapist")
      casa_case1 = create(:casa_case, case_number: "Hello")
      case_contact1 = create(:case_contact, want_driving_reimbursement: true, miles_driven: 5, creator: user1, contact_types: [contact_type1], occurred_at: Date.new(2020, 1, 1), casa_case: casa_case1)
      create(:case_contact, want_driving_reimbursement: false, miles_driven: 10, reimbursement_complete: false)
      create(:case_contact, want_driving_reimbursement: false)
      create(:case_contact, want_driving_reimbursement: true, miles_driven: 15, created_at: 2.years.ago)

      csv = described_class.new(case_contact1.casa_case.casa_org_id).to_csv
      parsed_csv = CSV.parse(csv)

      expect(parsed_csv.length).to eq(2)
      expect(parsed_csv[0].length).to eq(parsed_csv[1].length)
      expect(parsed_csv[0]).to eq([
        "Contact Types",
        "Occurred At",
        "Miles Driven",
        "Casa Case Number",
        "Creator Name",
        "Supervisor Name",
        "Volunteer Address",
        "Reimbursed"
      ])
      case_contact_data = parsed_csv[1]
      expect(case_contact_data[0]).to eq("Therapist")
      expect(case_contact_data[1]).to eq("January 1, 2020")
      expect(case_contact_data[2]).to eq("5")
      expect(case_contact_data[3]).to eq("Hello")
      expect(case_contact_data[4]).to eq("Linda")
    end

    it "generates an empty csv when there are no eligible case contacts" do
      faux_casa_org_id = 0
      csv = described_class.new(faux_casa_org_id).to_csv
      parsed_csv = CSV.parse(csv)

      expect(parsed_csv.length).to eq(1)
      expect(parsed_csv[0]).to eq([
        "Contact Types",
        "Occurred At",
        "Miles Driven",
        "Casa Case Number",
        "Creator Name",
        "Supervisor Name",
        "Volunteer Address",
        "Reimbursed"
      ])
    end

    it "includes case contacts from current org" do
      casa_org = create(:casa_org)
      create(:casa_case, casa_org: casa_org)
      create(:case_contact, want_driving_reimbursement: true, miles_driven: 15)

      csv = described_class.new(casa_org.id).to_csv
      parsed_csv = CSV.parse(csv)

      expect(parsed_csv.length).to eq(2)
    end

    it "excludes case contacts from other orgs" do
      casa_org = create(:casa_org)
      other_casa_org = create(:casa_org)
      casa_case = create(:casa_case, casa_org: other_casa_org)
      create(:case_contact, casa_case: casa_case, want_driving_reimbursement: true, miles_driven: 60)

      csv = described_class.new(casa_org.id).to_csv
      parsed_csv = CSV.parse(csv)

      expect(parsed_csv.length).to eq(1)
    end
  end
end

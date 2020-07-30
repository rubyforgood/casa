require "rails_helper"
require "csv"
RSpec.describe CaseContactReport, type: :model do
  describe "#generate_headers" do
    it "matches the length of row data" do
      case_contact = create(:case_contact)
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
        "Volunteer Email",
        "Volunteer Name",
        "Supervisor Name"
      ])
      case_contact_data = parsed_csv[1]
      expect(case_contact_data[1]).to eq("60")
    end
  end
end

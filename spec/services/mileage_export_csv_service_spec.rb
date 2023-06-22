require "rails_helper"

RSpec.describe MileageExportCsvService do
  subject { described_class.new(case_contacts).perform }
  let(:case_contacts) { CaseContact.where(id: case_contact) }
  let(:case_contact) { create(:case_contact) }

  it "creates CSV" do
    results = subject.split("\n")
    expect(results.count).to eq(2)
    expect(results[0].split(",")).to eq([
      "Contact Types",
      "Occurred At",
      "Miles Driven",
      "Casa Case Number",
      "Creator Name",
      "Supervisor Name",
      "Volunteer Address",
      "Reimbursed"
    ])
    expect(results[1].split(",").count).to eq(9)
  end
end

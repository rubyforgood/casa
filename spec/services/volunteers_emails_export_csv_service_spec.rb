require "rails_helper"

RSpec.describe VolunteersEmailsExportCsvService do
  subject { described_class.new().perform }

  before do
    create(:volunteer)
  end

  it "creates CSV" do
    binding.pry
    results = subject.split("\n")
    expect(results.count).to eq(2)
    expect(results[0].split(",")).to eq([
      "Email",
      "Case Number",
    ])
    expect(results[1].split(",").count).to eq(2)
  end
end

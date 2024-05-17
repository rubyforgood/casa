require "rails_helper"

RSpec.describe CasaCaseChangeService do
  subject { described_class.new(original, changed).changed_attributes_messages }

  context "with same original and changed" do
    let(:original) { create(:casa_case).full_attributes_hash }
    let(:changed) { original }
    it "does not show diff" do
      expect(subject).to eq(nil)
    end
  end

  context "with different original and changed" do
    let(:original) { create(:casa_case).full_attributes_hash }
    let(:changed) { create(:casa_case, :with_case_assignments, :with_one_court_order, :active, :with_case_contacts).full_attributes_hash }
    it "shows useful diff" do
      expect(subject).to match_array([
        "Changed Id",
        "Changed Case number",
        "Changed Created at",
        "Changed Birth month year youth",
        "1 Court order added or updated"
      ])
    end
  end
end

require "rails_helper"

RSpec.describe CaseCourtOrder, type: :model do
  subject { build(:case_court_order) }

  it { is_expected.to belong_to(:casa_case) }

  it { is_expected.to validate_presence_of(:text) }

  describe ".court_order_options" do
    it "returns standard court order options" do
      expect(described_class.court_order_options.count).to eq(23)
      expect(described_class.court_order_options).to be_an(Array)
      expect(described_class.court_order_options).to all be_an(Array)
    end
  end
end

require "rails_helper"

RSpec.describe CaseCourtOrder, type: :model do
  subject { build(:case_court_order) }

  it { is_expected.to belong_to(:casa_case) }

  it { is_expected.to validate_presence_of(:text) }

  describe ".standard_court_order_options" do
    it "returns standard court order options" do
      pending("returns standard court order options")
      # TODO
    end
  end
end

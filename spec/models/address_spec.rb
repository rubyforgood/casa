require "rails_helper"

RSpec.describe Address, type: :model do
  describe "validate associations" do
    it { is_expected.to belong_to(:user) }
  end
end

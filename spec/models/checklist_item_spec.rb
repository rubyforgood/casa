require "rails_helper"

RSpec.describe ChecklistItem, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:hearing_type) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:category) }
  end
end

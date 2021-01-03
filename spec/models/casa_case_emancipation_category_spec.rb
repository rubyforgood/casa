require "rails_helper"

RSpec.describe CasaCaseEmancipationCategory, type: :model do
  it { is_expected.to belong_to(:casa_case) }
  it { is_expected.to belong_to(:emancipation_category) }

  it "has a valid factory" do
    case_category_association = build(:casa_case_emancipation_category)
    expect(case_category_association.valid?).to be true
  end
end

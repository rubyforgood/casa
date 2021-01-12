require "rails_helper"

RSpec.describe CasaCaseEmancipationCategory, type: :model do
  it { is_expected.to belong_to(:casa_case) }
  it { is_expected.to belong_to(:emancipation_category) }

  it "does not allow adding the same category twice to a case" do
    expect {
      casa_case = create(:casa_case)
      emancipation_category = create(:emancipation_category)

      casa_case.emancipation_categories << emancipation_category
      casa_case.emancipation_categories << emancipation_category
    }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "has a valid factory" do
    case_category_association = build(:casa_case_emancipation_category)
    expect(case_category_association.valid?).to be true
  end
end

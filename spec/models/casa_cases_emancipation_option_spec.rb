require "rails_helper"

RSpec.describe CasaCasesEmancipationOption, type: :model do
  it { is_expected.to belong_to(:casa_case) }
  it { is_expected.to belong_to(:emancipation_option) }

  it "has a valid factory" do
    case_option_association = build(:casa_cases_emancipation_option)
    expect(case_option_association.valid?).to be true
  end
end

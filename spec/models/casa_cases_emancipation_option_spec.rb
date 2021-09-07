require "rails_helper"

RSpec.describe CasaCasesEmancipationOption, type: :model do
  it { is_expected.to belong_to(:casa_case) }
  it { is_expected.to belong_to(:emancipation_option) }

  it "does not allow adding the same category twice to a case" do
    expect {
      casa_case = create(:casa_case)
      emancipation_option = build(:emancipation_option)

      casa_case.emancipation_options << emancipation_option
      casa_case.emancipation_options << emancipation_option
    }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "has a valid factory" do
    case_option_association = build(:casa_cases_emancipation_option)
    expect(case_option_association.valid?).to be true
  end
end

require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to(belong_to(:casa_org)) }

  it { is_expected.to have_many(:case_assignments) }
  it { is_expected.to have_many(:casa_cases).through(:case_assignments) }

  it do
    is_expected.to(
      define_enum_for(:role).backed_by_column_of_type(:string)
    )
  end
end

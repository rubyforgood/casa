require 'rails_helper'

RSpec.describe CaseContact, type: :model do
  it { is_expected.to(belong_to(:creator).class_name("User")) }
  it { is_expected.to(belong_to(:casa_case)) }
  it do
    is_expected.to(
      define_enum_for(:contact_type).backed_by_column_of_type(:string)
    )
  end
end

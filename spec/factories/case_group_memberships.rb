FactoryBot.define do
  factory :case_group_membership do
    case_group { create(:case_group) }
    casa_case { create(:casa_case) }
  end
end

FactoryBot.define do
  factory :contact_type_group do
    casa_org { CasaOrg.first || create(:casa_org) }
    sequence(:name) { |n| "Group #{n}" }
  end
end

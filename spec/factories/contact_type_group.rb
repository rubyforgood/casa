FactoryBot.define do
  factory :contact_type_group do
    casa_org { association(:casa_org) }
    sequence(:name) { |n| "Group #{n}" }
  end
end

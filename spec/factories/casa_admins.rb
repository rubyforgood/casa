FactoryBot.define do
  factory :casa_admin, class: "CasaAdmin", parent: :user do
    sequence(:display_name) { |n| "CasaAdmin #{n}" }
    type { "CasaAdmin" }
  end
end

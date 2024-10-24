FactoryBot.define do
  factory :banner do
    casa_org
    user factory: :supervisor
    name { "Volunteer Survey" }
    active { true }
    content { "Please fill out this survey" }
  end
end

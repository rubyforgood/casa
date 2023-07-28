FactoryBot.define do
  factory :banner do
    name { "Volunteer Survey" }
    active { true }
    content { "Please fill out this survey" }
  end
end

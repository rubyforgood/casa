FactoryBot.define do
  factory :preference_set do
    user
    case_volunteer_columns { {} }
  end
end

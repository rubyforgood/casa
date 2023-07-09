FactoryBot.define do
  factory :preference_set do
    user
    case_volunteer_columns { {} }
    table_state { {} }
  end
end

FactoryBot.define do
  factory :followup do
    case_contact
    association :creator, factory: :user

    status { :requested }
  end
end

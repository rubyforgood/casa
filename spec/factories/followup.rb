FactoryBot.define do
  factory :followup do
    association :case_contact
    association :creator, factory: :user

    status { :requested }
  end
end

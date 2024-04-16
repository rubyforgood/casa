FactoryBot.define do
  factory :followup do
    association :creator, factory: :user
    status { :requested }
    case_contact

    # TODO polymorph Simulating the dual-writing or transitional setup during polymorphic migration
    # remove after migration completed
    after(:build) do |followup|
      followup.followupable = followup.case_contact
    end

    trait :with_note do
      note { Faker::Lorem.paragraph }
    end

    trait :without_note do
      note { "" }
    end
  end
end

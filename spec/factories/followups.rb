FactoryBot.define do
  factory :followup do
    association :creator, factory: :user
    status { :requested }
    case_contact

    # TODO polymorph Simulating the dual-writing setup during polymorphic migration
    # remove after migration completed
    after(:build) do |followup, evaluator|
      unless evaluator.instance_variable_defined?(:@without_dual_writing)
        followup.followupable = followup.case_contact
      end
    end

    trait :without_dual_writing do
      after(:build) do |followup|
        followup.followupable_id = nil
        followup.followupable_type = nil
      end
    end

    trait :with_note do
      note { Faker::Lorem.paragraph }
    end

    trait :without_note do
      note { "" }
    end
  end
end

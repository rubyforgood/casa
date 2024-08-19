FactoryBot.define do
  factory :followup do
    association :creator, factory: :user
    status { :requested }

    transient do
      followupable { create(:case_contact) }  # Default to creating a case_contact
    end

    after(:build) do |followup, evaluator|
      followup.followupable = evaluator.followupable
      # TODO: remove after done migrating polymorphic associations
      followup.case_contact_id = followup.followupable.id if followup.followupable.is_a?(CaseContact)
    end

    trait :with_note do
      note { Faker::Lorem.sentence }
    end

    trait :without_note do
      note { "" }
    end
  end
end

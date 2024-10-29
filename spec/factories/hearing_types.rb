FactoryBot.define do
  factory :hearing_type do
    casa_org { association(:casa_org) }
    sequence(:name) { |n| "Emergency Hearing #{n}" }
    active { true }

    trait :with_checklist_items do
      checklist_items { [association(:checklist_item, hearing_type: instance)] }
    end
  end
end

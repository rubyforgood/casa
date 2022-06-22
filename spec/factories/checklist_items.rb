FactoryBot.define do
  factory :checklist_item do
    description { "checklist item description" }
    category { "checklist item category" }
    mandatory { false }
    association :hearing_type
  end
end

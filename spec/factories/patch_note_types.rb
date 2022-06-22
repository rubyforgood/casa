FactoryBot.define do
  factory :patch_note_type do
    sequence(:name) { |n| "Patch Note Type #{n}" }
  end
end

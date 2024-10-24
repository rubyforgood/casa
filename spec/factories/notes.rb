FactoryBot.define do
  factory :note do
    notable factory: :user
    creator factory: :user
    content { "I am a note" }
  end
end

require "rails_helper"

RSpec.describe UserLanguage, type: :model do
  specify do
    expect(subject).to belong_to(:language)
    expect(subject).to belong_to(:user)
  end

  it "validates uniqueness of language scoped to user" do
    existing_record = create(:user_language)
    new_record = build(:user_language, user: existing_record.user, language: existing_record.language)
    expect(new_record).not_to be_valid
  end
end

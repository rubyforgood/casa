require "rails_helper"

RSpec.describe Language, type: :model do
  subject(:language) { build_stubbed :language }

  specify do
    expect(language).to belong_to(:casa_org)
    expect(language).to have_many(:user_languages)
    expect(language).to have_many(:users).through(:user_languages)

    expect(language).to validate_presence_of(:name)
  end

  describe "name uniqueness validation" do
    subject(:language) { create(:language, casa_org:, name:) }

    let(:casa_org) { create(:casa_org) }
    let(:name) { "spanish" }

    it "validates uniqueness of language for an organization" do
      create(:language, name:, casa_org:) # same language.name, same casa_org

      expect { language }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name has already been taken")
    end
  end

  describe "before_validation hook (#valid?)" do
    it "trims surrounding spaces from the name (not inside)" do
      language.name = " Western Punjabi "
      language.valid?
      expect(language.name).to eq "Western Punjabi"
    end
  end
end

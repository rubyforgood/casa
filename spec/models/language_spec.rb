require "rails_helper"

RSpec.describe Language, type: :model do
  it { is_expected.to belong_to(:casa_org) }
  it { is_expected.to have_many(:user_languages) }
  it { is_expected.to have_many(:users).through(:user_languages) }

  it { is_expected.to validate_presence_of(:name) }
end

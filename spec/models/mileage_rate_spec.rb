require "rails_helper"

RSpec.describe MileageRate, type: :model do
  subject { build(:mileage_rate) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_uniqueness_of(:effective_date).scoped_to(:is_active) }
  it { is_expected.to validate_presence_of(:effective_date) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:amount) }
end

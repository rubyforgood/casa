require 'rails_helper'

RSpec.describe MileageRate, type: :model do
  subject { build(:mileage_rate) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_uniqueness_of(:effective_date).scoped_to(:is_active) }
end

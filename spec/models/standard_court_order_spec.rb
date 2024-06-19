require 'rails_helper'

RSpec.describe StandardCourtOrder, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:casa_org) }
  end

  describe 'validations' do
    subject { FactoryBot.build(:standard_court_order) }

    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to validate_uniqueness_of(:value).scoped_to(:casa_org_id).case_insensitive }
  end
end

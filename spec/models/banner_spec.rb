require 'rails_helper'

RSpec.describe Banner, type: :model do
  describe '#valid?' do
    it 'does not allow multiple active banners for same organization' do
      casa_org = create(:casa_org)
      supervisor = create(:supervisor)
      create(:banner, casa_org: casa_org, user: supervisor)

      banner = build(:banner, casa_org: casa_org, user: supervisor)
      expect(banner).to_not be_valid
    end

    it 'does allow multiple active banners for different organization' do
      casa_org = create(:casa_org)
      supervisor = create(:supervisor, casa_org: casa_org)
      create(:banner, casa_org: casa_org, user: supervisor)

      another_org = create(:casa_org)
      another_supervisor = create(:supervisor, casa_org: another_org)
      banner = build(:banner, casa_org: another_org, user: another_supervisor)
      expect(banner).to be_valid
    end
  end
end

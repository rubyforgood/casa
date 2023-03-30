require "rails_helper"

RSpec.describe PlacementType, type: :model do
  let!(:object) { create(:placement_type) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to belong_to(:casa_org) }
end

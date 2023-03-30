require "rails_helper"

RSpec.describe Placement, type: :model do
  let!(:object) { create(:placement) }

  it { is_expected.to belong_to(:placement_type) }
  it { is_expected.to belong_to(:creator) }
end

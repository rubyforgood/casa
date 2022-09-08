require "rails_helper"

RSpec.describe Language, type: :model do
  it { is_expected.to belong_to(:casa_org) }
  it { is_expected.to have_and_belong_to_many(:users) }
end

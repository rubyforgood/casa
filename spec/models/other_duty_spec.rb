require "rails_helper"

RSpec.describe OtherDuty, type: :model do
  it { is_expected.to belong_to(:creator) }
end

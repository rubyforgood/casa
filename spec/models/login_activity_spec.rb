require 'rails_helper'

RSpec.describe LoginActivity, type: :model do
  it { is_expected.to belong_to(:user) }

  it "has a valid factory" do
    expect(build(:login_activity).valid?).to be true
  end
end

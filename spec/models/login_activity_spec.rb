require "rails_helper"

RSpec.describe LoginActivity, type: :model do
  it "has a valid factory" do
    login_activity = build(:login_activity)

    expect(login_activity).to be_valid
  end
end

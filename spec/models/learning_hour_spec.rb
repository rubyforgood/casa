require "rails_helper"

RSpec.describe LearningHour, type: :model do
  it "belongs to a volunteer" do
    learning_hour = build_stubbed(:learning_hour, user_id: nil)
    expect(learning_hour).to_not be_valid
    expect(learning_hour.errors[:user_id]).to eq(["must exist"])
  end
end

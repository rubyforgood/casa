require "rails_helper"

RSpec.describe CaseGroup, type: :model do
  it "has a valid factory" do
    case_group = build(:case_group)

    expect(case_group).to be_valid
  end
end

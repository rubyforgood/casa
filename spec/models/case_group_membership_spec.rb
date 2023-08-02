require "rails_helper"

RSpec.describe CaseGroupMembership, type: :model do
  it "has a valid factory" do
    case_group_membership = build(:case_group_membership)

    expect(case_group_membership).to be_valid
  end
end

require "rails_helper"

RSpec.describe CaseGroup, type: :model do
  describe "validations" do
    it { should validate_presence_of(:case_group_memberships) }

    it "validates uniqueness of name scoped to casa_org" do
      casa_org = create(:casa_org)
      create(:case_group, casa_org: casa_org, name: "The Johnson Family")
      non_uniq_case_group = build(:case_group, casa_org: casa_org, name: "The Johnson Family")
      non_uniq_case_group_whitespace = build(:case_group, casa_org: casa_org, name: "The Johnson Family   ")
      non_uniq_case_group_case_sensitive = build(:case_group, casa_org: casa_org, name: "The Johnson family")

      expect(non_uniq_case_group).to_not be_valid
      expect(non_uniq_case_group_case_sensitive).to_not be_valid
      expect(non_uniq_case_group_whitespace).to_not be_valid
      expect(non_uniq_case_group.errors[:name]).to include("has already been taken")
      expect(non_uniq_case_group_case_sensitive.errors[:name]).to include("has already been taken")
      expect(non_uniq_case_group_whitespace.errors[:name]).to include("has already been taken")
    end
  end

  describe "relationships" do
    it { should have_many(:case_group_memberships) }
    it { should have_many(:casa_cases).through(:case_group_memberships) }
  end

  it "has a valid factory" do
    case_group = build(:case_group)

    expect(case_group).to be_valid
  end
end

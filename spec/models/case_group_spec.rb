require "rails_helper"

RSpec.describe CaseGroup do
  subject(:case_group) { build_stubbed(:case_group) }

  specify do
    expect(subject).to have_many(:case_group_memberships)
    expect(subject).to have_many(:casa_cases).through(:case_group_memberships)

    expect(subject).to validate_presence_of(:case_group_memberships)
  end

  it "validates uniqueness of name scoped to casa_org" do
    casa_org = create(:casa_org)
    create(:case_group, casa_org: casa_org, name: "The Johnson Family")
    non_uniq_case_group = build(:case_group, casa_org: casa_org, name: "The Johnson Family")
    non_uniq_case_group_whitespace = build(:case_group, casa_org: casa_org, name: "The Johnson Family   ")
    non_uniq_case_group_case_sensitive = build(:case_group, casa_org: casa_org, name: "The Johnson family")

    expect(non_uniq_case_group).not_to be_valid
    expect(non_uniq_case_group_case_sensitive).not_to be_valid
    expect(non_uniq_case_group_whitespace).not_to be_valid
    expect(non_uniq_case_group.errors[:name]).to include("has already been taken")
    expect(non_uniq_case_group_case_sensitive.errors[:name]).to include("has already been taken")
    expect(non_uniq_case_group_whitespace.errors[:name]).to include("has already been taken")
  end
end

require "rails_helper"

RSpec.describe Followup, type: :model do
  subject { build(:followup) }

  it { is_expected.to belong_to(:creator).class_name("User") }
  it { is_expected.to belong_to(:followupable).optional }

  it "should have polymorphic fields" do
    expect(Followup.new).to respond_to(:followupable_id)
    expect(Followup.new).to respond_to(:followupable_type)
  end

  # TODO polymorph temporary test for dual writing
  it "writes to case_contact_id and both polymorphic columns when creating new followups" do
    case_contact = build_stubbed(:case_contact)
    followup = create(:followup, :with_note, followupable: case_contact)

    expect(followup.case_contact_id).to_not be_nil
    expect(followup.followupable_id).to_not be_nil
    expect(followup.followupable_type).to eq "CaseContact"
    expect(followup.followupable_id).to eq followup.case_contact_id
  end

  it "only allows 1 followup in requested status" do
    case_contact = create(:case_contact)  # Persist the case_contact in the database
    create(:followup, followupable: case_contact)
    invalid_followup = build(:followup, status: :requested, followupable: case_contact)

    expect(invalid_followup).to be_invalid
    expect(invalid_followup.errors[:base]).to include("Only 1 Followup can be in requested status.")
  end

  it "allows followup to be flipped to resolved" do
    followup = create(:followup, :with_note)

    expect(followup.resolved!).to be_truthy
  end

  describe ".in_organization" do
    let!(:first_org) { create(:casa_org) }
    # this needs to run first so it is generated using a new "default" organization
    let!(:followup_first_org) { create(:followup, followupable: create(:case_contact, casa_case: create(:casa_case, casa_org: first_org))) }

    # then these lets are generated for the org_to_search organization
    let!(:second_org) { create(:casa_org) }
    let!(:casa_case) { create(:casa_case, casa_org: second_org) }
    let!(:casa_case_another) { create(:casa_case, casa_org: second_org) }
    let!(:case_contact) { create(:case_contact, casa_case: casa_case) }
    let!(:case_contact_another) { create(:case_contact, casa_case: casa_case_another) }
    let!(:followup_second_org) { create(:followup, followupable: case_contact) }
    let!(:followup_second_org_another) { create(:followup, followupable: case_contact_another) }

    subject { described_class.in_organization(second_org) }

    it "should include followups from same organization" do
      expect(subject).to contain_exactly(followup_second_org, followup_second_org_another)
    end

    it "should exclude followups from other organizations" do
      expect(subject).to_not include(followup_first_org)
    end
  end

  describe 'callbacks' do
    let(:case_contact) { create(:case_contact) }
    let(:non_case_contact) { create(:casa_case) }

    it 'sets case_contact_id when followupable is a CaseContact' do
      followup = build(:followup, followupable: case_contact)
      followup.save
      expect(followup.case_contact_id).to eq(case_contact.id)
    end

    it 'clears case_contact_id when followupable is not a CaseContact' do
      followup = build(:followup, followupable: non_case_contact)
      followup.save
      expect(followup.case_contact_id).to be_nil
    end
  end
end

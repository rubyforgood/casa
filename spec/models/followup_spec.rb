require "rails_helper"

RSpec.describe Followup, type: :model do
  subject { build(:followup) }

  it { is_expected.to belong_to(:case_contact) }
  it { is_expected.to belong_to(:creator).class_name("User") }

  it "only allows 1 followup in requested status" do
    case_contact = build_stubbed(:case_contact)
    create(:followup, status: :requested, case_contact: case_contact)
    invalid_followup = build(:followup, status: :requested, case_contact: case_contact)

    expect(invalid_followup).to be_invalid
  end

  it "allows followup to be flipped to resolved" do
    followup = create(:followup, status: :requested)

    expect(followup.resolved!).to be_truthy
  end
end

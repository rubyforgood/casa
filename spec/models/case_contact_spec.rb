require "rails_helper"

RSpec.describe CaseContact, type: :model do
  it "belongs to a creator" do
    case_contact = build(:case_contact, creator: nil)
    expect(case_contact).to_not be_valid
    expect(case_contact.errors[:creator]).to eq(["must exist"])
  end

  it "belongs to a casa case" do
    case_contact = build(:case_contact, casa_case: nil)
    expect(case_contact).to_not be_valid
    expect(case_contact.errors[:casa_case]).to eq(["must exist"])
  end

  it "validates presence of contact types" do
    case_contact = build(:case_contact, contact_types: nil)
    expect(case_contact).to_not be_valid
    expect(case_contact.errors[:contact_types]).to eq(["can't be blank"])
  end

  it "validates contact types are of allowed types" do
    case_contact = build(:case_contact, contact_types: ["popcorn"])
    expect(case_contact).to_not be_valid
    expect(case_contact.errors[:contact_types]).to eq(["must have valid contact types"])
  end

  it "verifies occurred at is not in the future" do
    case_contact = build(:case_contact, occurred_at: Time.now + 1.week)
    expect(case_contact).to_not be_valid
    expect(case_contact.errors[:occurred_at]).to eq(["cannot be in the future"])
  end
end


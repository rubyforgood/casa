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

  it "validates presence of occurred_at" do
    case_contact = build(:case_contact, occurred_at: nil)
    expect(case_contact).to_not be_valid
    expect(case_contact.errors[:occurred_at]).to eq(["can't be blank"])
  end

  it "validates duration_minutes is only numeric values" do
    case_contact = build(:case_contact, duration_minutes: nil)
    expect(case_contact).to_not be_valid
    expect(case_contact.errors[:duration_minutes]).to eq(["Minimum case contact duration should be 15 minutes."])
  end

  it "validates duration_minutes cannot be less than 15 minutes." do
    case_contact = build(:case_contact, duration_minutes: 10)
    expect(case_contact).to_not be_valid
    expect(case_contact.errors[:duration_minutes]).to eq(["Minimum case contact duration should be 15 minutes."])
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

  it "validates want_driving_reimbursement can be true when miles_driven is  positive" do
    case_contact = build(:case_contact, want_driving_reimbursement: true, miles_driven: 1)
    expect(case_contact).to be_valid
  end

  it "validates want_driving_reimbursement cannot be true when miles_driven is nil" do
    case_contact = build(:case_contact, want_driving_reimbursement: true, miles_driven: nil)
    expect(case_contact).not_to be_valid
    expect(case_contact.errors[:base]).to eq(["Must enter miles driven to receive driving reimbursement."])
  end

  it "validates want_driving_reimbursement cannot be true when miles_driven is not positive" do
    case_contact = build(:case_contact, want_driving_reimbursement: true, miles_driven: 0)
    expect(case_contact).not_to be_valid
    expect(case_contact.errors[:base]).to eq(["Must enter miles driven to receive driving reimbursement."])
  end

  it "validates that contact_made cannot be null" do
    case_contact = build(:case_contact, contact_made: nil)
    expect(case_contact).not_to be_valid
    expect(case_contact.errors[:base]).to eq(["Must enter whether the contact was made."])
  end

  it "can be updated when occured_at is before the last day of the month in the quarter that the case contact was created" do
    case_contact = create(:case_contact)
    case_contact.update(occurred_at: Time.zone.now)
    expect(case_contact).to be_valid
  end

  it "can't be updated when occured_at is after the last day of the month in the quarter that the case contact was created" do
    case_contact = create(:case_contact, occurred_at: Time.zone.now - 1.year)
    expect(case_contact).to_not be_valid
    expect(case_contact.errors[:base]).to eq(["cannot edit past case contacts outside of quarter"])
  end
end

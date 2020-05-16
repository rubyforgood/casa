require "rails_helper"

RSpec.describe CaseContact, type: :model do
  it { is_expected.to(belong_to(:creator).class_name("User")) }
  it { is_expected.to(belong_to(:casa_case)) }
  it { is_expected.to(validate_presence_of(:contact_types)) }
  it "verifies occured at is not in the future" do
    case_contact = create(:case_contact, occurred_at: Time.now + 1.week)
    expect(case_contact).to_not be_valid
    expect(case_contact.errors[:occurred_at]).to eq("occured_at cannot be in the future")
  end
end


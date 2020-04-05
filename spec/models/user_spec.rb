require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to(belong_to(:casa_org)) }

  it { is_expected.to have_many(:case_assignments) }
  it { is_expected.to have_many(:casa_cases).through(:case_assignments) }

  it do
    is_expected.to(
      define_enum_for(:role).backed_by_column_of_type(:string)
    )
  end

  it "returns all case_contacts associated with this user and the casa case id supplied" do

    volunteer_1 = create(:user, :volunteer, :with_casa_cases)

    case_of_interest = volunteer_1.casa_cases.first
    create(:case_contact, creator: volunteer_1, casa_case: case_of_interest)
    create(:case_contact, creator: volunteer_1, casa_case: volunteer_1.casa_cases.second)

    sample_casa_case_id = case_of_interest.id

    result = volunteer_1.case_contacts_for(sample_casa_case_id)

    expect(result.length).to eq(1)
  end

  it "does not return case_contacts associated with another volunteer user" do
    volunteer_1 = create(:user, :volunteer, :with_casa_cases)
    volunteer_2 = create(:user, :volunteer, :with_casa_cases)

    case_of_interest = volunteer_1.casa_cases.first
    create(:case_contact, creator: volunteer_1, casa_case: case_of_interest)
    create(:case_contact, creator: volunteer_1, casa_case: volunteer_1.casa_cases.second)
    create(:case_assignment, casa_case: case_of_interest, volunteer: volunteer_2)
    create(:case_contact, creator: volunteer_2, casa_case: case_of_interest)
    create(:case_contact)

    sample_casa_case_id = case_of_interest.id

    result = volunteer_1.case_contacts_for(sample_casa_case_id)
    expect(result.length).to eq(1)
    result = volunteer_2.case_contacts_for(sample_casa_case_id)
    expect(result.length).to eq(1)
  end
end

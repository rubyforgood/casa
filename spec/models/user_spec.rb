require "rails_helper"

RSpec.describe User, type: :model do
  it { is_expected.to(belong_to(:casa_org)) }

  it { is_expected.to have_many(:case_assignments) }
  it { is_expected.to have_many(:casa_cases).through(:case_assignments) }
  it { is_expected.to have_many(:case_contacts) }

  it { is_expected.to have_many(:supervisor_volunteers) }
  it { is_expected.to have_many(:volunteers).through(:supervisor_volunteers) }

  it { is_expected.to have_one(:supervisor_volunteer) }
  it { is_expected.to have_one(:supervisor).through(:supervisor_volunteer) }

  it { is_expected.to(define_enum_for(:role).backed_by_column_of_type(:string)) }

  it "returns all case_contacts associated with this user and the casa case id supplied" do
    volunteer = create(:user, :volunteer, :with_casa_cases)

    case_of_interest = volunteer.casa_cases.first
    create(:case_contact, creator: volunteer, casa_case: case_of_interest)
    create(:case_contact, creator: volunteer, casa_case: volunteer.casa_cases.second)

    sample_casa_case_id = case_of_interest.id

    result = volunteer.case_contacts_for(sample_casa_case_id)

    expect(result.length).to eq(1)
  end

  it "does not return case_contacts associated with another volunteer user" do
    volunteer = create(:user, :volunteer, :with_casa_cases)
    other_volunteer = create(:user, :volunteer, :with_casa_cases)

    case_of_interest = volunteer.casa_cases.first
    create(:case_contact, creator: volunteer, casa_case: case_of_interest)
    create(:case_contact, creator: volunteer, casa_case: volunteer.casa_cases.second)
    create(:case_assignment, casa_case: case_of_interest, volunteer: other_volunteer)
    create(:case_contact, creator: other_volunteer, casa_case: case_of_interest)
    create(:case_contact)

    sample_casa_case_id = case_of_interest.id

    result = volunteer.case_contacts_for(sample_casa_case_id)
    expect(result.length).to eq(1)
    result = other_volunteer.case_contacts_for(sample_casa_case_id)
    expect(result.length).to eq(1)
  end
end

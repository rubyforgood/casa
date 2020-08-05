require "rails_helper"

RSpec.describe User, type: :model do
  it { is_expected.to belong_to(:casa_org) }

  it { is_expected.to have_many(:case_assignments) }
  it { is_expected.to have_many(:casa_cases).through(:case_assignments) }
  it { is_expected.to have_many(:case_contacts) }

  it { is_expected.to have_many(:supervisor_volunteers) }
  it { is_expected.to have_many(:volunteers).through(:supervisor_volunteers) }

  it { is_expected.to have_one(:supervisor_volunteer) }
  it { is_expected.to have_one(:supervisor).through(:supervisor_volunteer) }

  it "returns all case_contacts associated with this user and the casa case id supplied" do
    volunteer = create(:volunteer, :with_casa_cases)

    case_of_interest = volunteer.casa_cases.first
    create(:case_contact, creator: volunteer, casa_case: case_of_interest)
    create(:case_contact, creator: volunteer, casa_case: volunteer.casa_cases.second)

    sample_casa_case_id = case_of_interest.id

    result = volunteer.case_contacts_for(sample_casa_case_id)

    expect(result.length).to eq(1)
  end

  it "does not return case_contacts associated with another volunteer user" do
    volunteer = create(:volunteer, :with_casa_cases)
    other_volunteer = create(:volunteer, :with_casa_cases)

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

  describe "#active_for_authentication?" do
    it "is false when the user is inactive" do
      user = create(:volunteer, :inactive)
      expect(user).not_to be_active_for_authentication
      expect(user.inactive_message).to eq(:inactive)
    end

    it "is true otherwise" do
      user = create(:volunteer)
      expect(user).to be_active_for_authentication

      user = create(:supervisor)
      expect(user).to be_active_for_authentication
    end
  end

  describe "#serving_transition_aged_youth?" do
    let(:case_assignment_with_a_transition_aged_youth) do
      create(:case_assignment, casa_case: create(:casa_case, transition_aged_youth: true))
    end
    let(:case_assignment_without_transition_aged_youth) do
      create(:case_assignment, casa_case: create(:casa_case, transition_aged_youth: false))
    end

    context "when the user has a transition-aged-youth case" do
      it "is true" do
        case_assignments = [
            case_assignment_with_a_transition_aged_youth,
            case_assignment_without_transition_aged_youth
        ]
        user = create(:volunteer, case_assignments: case_assignments)

        expect(user).to be_serving_transition_aged_youth
      end
    end

    context "when the user does not have a transition-aged-youth case" do
      it "is false" do
        case_assignments = [case_assignment_without_transition_aged_youth]
        user = create(:volunteer, case_assignments: case_assignments)

        expect(user).not_to be_serving_transition_aged_youth
      end
    end
  end

  describe "#volunteers_with_no_supervisor?" do
    subject { Supervisor.volunteers_with_no_supervisor(casa_org) }
    let(:casa_org) { create(:casa_org) }
    context "no volunteers" do
      it "returns none" do
        expect(subject).to eq([])
      end
    end
    context "volunteers" do
      let!(:unassigned1) { create(:volunteer, display_name: 'aaa', casa_org: casa_org) }
      let!(:unassigned2) { create(:volunteer, display_name: 'bbb', casa_org: casa_org) }
      let!(:unassigned2_different_org) { create(:volunteer, display_name: 'ccc',) }
      let!(:assignment1) { create(:supervisor_volunteer, volunteer: assigned1) }
      let!(:assigned1) { create(:volunteer, display_name: 'ddd', casa_org: casa_org) }
      let!(:assignment1) { create(:supervisor_volunteer, volunteer: assigned1) }
      let!(:assigned2_different_org) { assignment1.volunteer }
      let!(:unassigned_inactive) { create(:volunteer, display_name: 'eee', casa_org: casa_org, active: false) }

      it "returns unassigned volunteers" do
        expect(subject.map(&:display_name).sort).to eq(['aaa', 'bbb'])
      end
    end
  end
end

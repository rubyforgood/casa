require "rails_helper"

RSpec.describe User, type: :model do
  it { is_expected.to belong_to(:casa_org) }

  it { is_expected.to have_many(:case_assignments) }
  it { is_expected.to have_many(:casa_cases).through(:case_assignments) }
  it { is_expected.to have_many(:case_contacts) }
  it { is_expected.to have_many(:sent_emails) }
  it { is_expected.to have_many(:user_languages) }
  it { is_expected.to have_many(:languages).through(:user_languages) }

  it { is_expected.to have_many(:followups).with_foreign_key(:creator_id) }

  it { is_expected.to have_one(:supervisor_volunteer) }
  it { is_expected.to have_one(:supervisor).through(:supervisor_volunteer) }

  it { is_expected.to have_many(:notes) }

  describe "model validations" do
    it "requires display name" do
      user = build(:user, display_name: "")
      expect(user.valid?).to be false
    end

    it "requires email" do
      user = build(:user, email: "")
      expect(user.valid?).to be false
    end

    it "requires 12 digit phone numbers" do
      user = build(:user, phone_number: "+1416321809")
      expect(user.valid?).to be false
    end

    it "requires phone number to only contain numbers" do
      user = build(:user, phone_number: "+1416eee4325")
      expect(user.valid?).to be false
    end

    it "requires phone number with US area code" do
      user = build(:user, phone_number: "+76758890432")
      expect(user.valid?).to be false
    end
  end

  describe "#case_contacts_for" do
    let(:volunteer) { create(:volunteer, :with_casa_cases) }
    let(:case_of_interest) { volunteer.casa_cases.first }
    let!(:contact_a) { create(:case_contact, creator: volunteer, casa_case: case_of_interest) }
    let!(:contact_b) { create(:case_contact, creator: volunteer, casa_case: volunteer.casa_cases.second) }

    it "returns all case_contacts associated with this user and the casa case id supplied" do
      sample_casa_case_id = case_of_interest.id

      result = volunteer.case_contacts_for(sample_casa_case_id)

      expect(result.length).to eq(1)
    end

    it "does not return case_contacts associated with another volunteer user" do
      other_volunteer = build(:volunteer, :with_casa_cases, casa_org: volunteer.casa_org)

      create(:case_assignment, casa_case: case_of_interest, volunteer: other_volunteer)
      create(:case_contact, creator: other_volunteer, casa_case: case_of_interest)
      build_stubbed(:case_contact)

      sample_casa_case_id = case_of_interest.id

      result = volunteer.case_contacts_for(sample_casa_case_id)
      expect(result.length).to eq(1)
      result = other_volunteer.case_contacts_for(sample_casa_case_id)
      expect(result.length).to eq(1)
    end

    it "does not return case_contacts neither unassigned cases or inactive cases" do
      inactive_case_assignment = build_stubbed(:case_assignment, casa_case: build_stubbed(:casa_case, casa_org: volunteer.casa_org), active: false, volunteer: volunteer)
      case_assignment_to_inactve_case = build_stubbed(:case_assignment, casa_case: build_stubbed(:casa_case, active: false, casa_org: volunteer.casa_org), volunteer: volunteer)

      expect {
        volunteer.case_contacts_for(inactive_case_assignment.casa_case.id)
      }.to raise_error(ActiveRecord::RecordNotFound)

      expect {
        volunteer.case_contacts_for(case_assignment_to_inactve_case.casa_case.id)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "supervisors" do
    describe "#volunteers_serving_transition_aged_youth" do
      let(:casa_org) { build(:casa_org) }
      let(:supervisor) { build(:supervisor, casa_org: casa_org) }

      it "returns the number of transition aged youth on a supervisor" do
        casa_cases = [
          build(:casa_case, casa_org: casa_org),
          build(:casa_case, casa_org: casa_org),
          create(:casa_case, :pre_transition, casa_org: casa_org)
        ]

        casa_cases.each do |casa_case|
          volunteer = create(:volunteer, supervisor: supervisor, casa_org: casa_org)
          volunteer.casa_cases << casa_case
        end

        expect(supervisor.volunteers_serving_transition_aged_youth).to eq(2)
      end

      it "ignores volunteers' inactive and unassgined cases" do
        volunteer = create(:volunteer, supervisor: supervisor, casa_org: casa_org)
        build_stubbed(:case_assignment, casa_case: build_stubbed(:casa_case, casa_org: casa_org, active: false), volunteer: volunteer)
        build_stubbed(:case_assignment, casa_case: build_stubbed(:casa_case, casa_org: casa_org), active: false, volunteer: volunteer)

        expect(supervisor.volunteers_serving_transition_aged_youth).to eq(0)
      end
    end

    describe "#no_attempt_for_two_weeks" do
      let(:supervisor) { create(:supervisor) }

      it "returns zero for a volunteer that has attempted contact in at least one contact_case within the last 2 weeks" do
        volunteer_1 = create(:volunteer, :with_casa_cases, supervisor: supervisor)

        case_of_interest_1 = volunteer_1.casa_cases.first
        create(:case_contact, creator: volunteer_1, casa_case: case_of_interest_1, contact_made: true, occurred_at: 1.week.ago)
        expect(supervisor.no_attempt_for_two_weeks).to eq(0)
      end

      it "returns one for a supervisor with two volunteers, only one of which has a contact newer than 2 weeks old" do
        volunteer_1 = create(:volunteer, :with_casa_cases, supervisor: supervisor)
        volunteer_2 = create(:volunteer, :with_casa_cases, supervisor: supervisor)

        case_of_interest_1 = volunteer_1.casa_cases.first
        case_of_interest_2 = volunteer_2.casa_cases.first
        create(:case_contact, creator: volunteer_1, casa_case: case_of_interest_1, contact_made: true, occurred_at: 1.week.ago)
        create(:case_contact, creator: volunteer_2, casa_case: case_of_interest_2, contact_made: true, occurred_at: 3.weeks.ago)
        expect(supervisor.no_attempt_for_two_weeks).to eq(1)
      end

      it "returns one for a volunteer that has not made any contact_cases within the last 2 weeks" do
        create(:volunteer, :with_casa_cases, supervisor: supervisor)
        expect(supervisor.no_attempt_for_two_weeks).to eq(1)
      end

      it "returns zero for a volunteer that is not assigned to any casa cases" do
        build_stubbed(:volunteer, supervisor: supervisor)
        expect(supervisor.no_attempt_for_two_weeks).to eq(0)
      end

      it "returns one for a volunteer who has attempted contact in at least one contact_case with occurred_at after 2 weeks" do
        volunteer_1 = create(:volunteer, :with_casa_cases, supervisor: supervisor)

        case_of_interest_1 = volunteer_1.casa_cases.first

        build_stubbed(:case_contact, creator: volunteer_1, casa_case: case_of_interest_1, contact_made: true, occurred_at: 3.weeks.ago)
        expect(supervisor.no_attempt_for_two_weeks).to eq(1)
      end

      it "returns zero for a volunteer that has no active casa case assignments" do
        volunteer_1 = create(:volunteer, :with_casa_cases, supervisor: supervisor)

        case_of_interest_1 = volunteer_1.casa_cases.first
        case_of_interest_2 = volunteer_1.casa_cases.last
        case_assignment_1 = case_of_interest_1.case_assignments.find_by(volunteer: volunteer_1)
        case_assignment_2 = case_of_interest_2.case_assignments.find_by(volunteer: volunteer_1)
        case_assignment_1.update!(active: false)
        case_assignment_2.update!(active: false)

        expect(supervisor.no_attempt_for_two_weeks).to eq(0)
      end
    end
  end

  describe "#active_for_authentication?" do
    it "is false when the user is inactive" do
      user = build_stubbed(:volunteer, :inactive)
      expect(user).not_to be_active_for_authentication
      expect(user.inactive_message).to eq(:inactive)
    end

    it "is true otherwise" do
      user = build_stubbed(:volunteer)
      expect(user).to be_active_for_authentication

      user = build_stubbed(:supervisor)
      expect(user).to be_active_for_authentication
    end
  end

  describe "#actively_assigned_and_active_cases" do
    let(:user) { build(:volunteer) }
    let!(:active_case_assignment_with_active_case) do
      create(:case_assignment, casa_case: build(:casa_case, casa_org: user.casa_org), volunteer: user)
    end
    let!(:active_case_assignment_with_inactive_case) do
      create(:case_assignment, casa_case: build(:casa_case, casa_org: user.casa_org, active: false), volunteer: user)
    end
    let!(:inactive_case_assignment_with_active_case) do
      create(:case_assignment, casa_case: build(:casa_case, casa_org: user.casa_org), active: false, volunteer: user)
    end
    let!(:inactive_case_assignment_with_inactive_case) do
      create(:case_assignment, casa_case: build(:casa_case, casa_org: user.casa_org, active: false), active: false, volunteer: user)
    end

    it "only returns the user's active cases with active case assignments" do
      expect(user.actively_assigned_and_active_cases).to match_array([active_case_assignment_with_active_case.casa_case])
    end
  end

  describe "#serving_transition_aged_youth?" do
    let(:user) { build(:volunteer) }
    let!(:case_assignment_without_transition_aged_youth) do
      build(:case_assignment, casa_case: build_stubbed(:casa_case, :pre_transition, casa_org: user.casa_org), volunteer: user)
    end

    context "when the user has a transition-aged-youth case" do
      it "is true" do
        create(:case_assignment, casa_case: build(:casa_case, casa_org: user.casa_org), volunteer: user)
        expect(user).to be_serving_transition_aged_youth
      end
    end

    context "when the user does not have a transition-aged-youth case" do
      it "is false" do
        expect(user).not_to be_serving_transition_aged_youth
      end
    end

    context "when the user's only transition-aged-youth case is inactive" do
      it "is false" do
        build(:case_assignment, casa_case: build_stubbed(:casa_case, casa_org: user.casa_org, active: false), volunteer: user)

        expect(user).not_to be_serving_transition_aged_youth
      end
    end

    context "when the user is unassigned from a transition-aged-youth case" do
      it "is false" do
        build(:case_assignment, casa_case: build_stubbed(:casa_case, casa_org: user.casa_org), volunteer: user, active: false)

        expect(user).not_to be_serving_transition_aged_youth
      end
    end
  end

  context "when there is an associated Other Duty record" do
    let(:user) { create(:supervisor) }
    let!(:duty) { create(:other_duty, creator: user) }

    it "cannot be destroyed without destroying the associated Other Duty record" do
      expect { user.delete }.to raise_error ActiveRecord::InvalidForeignKey
    end
  end

  describe ".no_recent_sign_in" do
    let!(:old_sign_in_user) { create(:user, last_sign_in_at: 39.days.ago) }
    let!(:recently_signed_in_user) { create(:user, last_sign_in_at: 5.days.ago) }

    it "returns users who haven't signed in in 30 days" do
      expect(User.no_recent_sign_in).to contain_exactly(old_sign_in_user)
    end
  end

  describe "#record_previous_emails" do
    # create user, check for side effects, test method
    let!(:new_volunteer) { create(:volunteer, email: "firstemail@example.com") }

    it "instantiates with an empty old_emails attribute" do
      # brand new account, old emails array is empty
      expect(new_volunteer.old_emails).to match_array([])
    end

    it "saves the old email when a volunteer changes their email" do
      # email is changed and recorded
      new_volunteer.update(email: "secondemail@example.com")

      expect(new_volunteer.email).to eq("secondemail@example.com")
      expect(new_volunteer.old_emails).to match_array(["firstemail@example.com"])
    end

    it "removes a previous email from old_emails if volunteer reinstates it" do
      # email is changed to previously used email and is no longer recorded as an "old email"
      new_volunteer.update(email: "secondemail@example.com")
      new_volunteer.update(email: "firstemail@example.com")

      expect(new_volunteer.email).to eq("firstemail@example.com")
      expect(new_volunteer.old_emails).to match_array(["secondemail@example.com"])
      expect(new_volunteer.old_emails).not_to include("firstemail@example.com")
    end
  end
end

require "rails_helper"

RSpec.describe CaseContact do
  subject(:case_contact) { build_stubbed :case_contact }

  let(:casa_org) { case_contact.casa_org }

  specify(:aggregate_failures) do
    expect(case_contact).to have_many(:contact_topic_answers).dependent(:destroy)
    expect(case_contact).to belong_to(:creator).optional(false)
    expect(case_contact).to belong_to(:casa_case).optional(true)
    expect(case_contact).to have_one(:casa_org).through(:casa_case)
    expect(case_contact).to have_one(:creator_casa_org).through(:creator)

    expect(case_contact).to validate_numericality_of(:miles_driven).is_less_than 10_000
    expect(case_contact).to validate_numericality_of(:miles_driven).is_greater_than_or_equal_to 0
    expect(case_contact).to validate_presence_of(:casa_case_id)
    expect(case_contact).to validate_presence_of(:occurred_at)
    expect(case_contact).to validate_presence_of(:duration_minutes)

    expect(case_contact).to have_db_column(:miles_driven).with_options(default: 0)
  end

  context "status is 'active'" do
    it "verifies occurred at is not in the future" do
      case_contact.occurred_at = 1.week.from_now
      expect(case_contact).not_to be_valid
      expect(case_contact.errors[:occurred_at]).to eq(["can't be in the future"])
      expect(case_contact.errors.full_messages).to include("Date can't be in the future")
    end

    it "verifies occurred at is not before 1/1/1989" do
      case_contact.occurred_at = "1984-01-01".to_date
      expect(case_contact).not_to be_valid
      expect(case_contact.errors[:occurred_at]).to eq(["can't be prior to 01/01/1989."])
      expect(case_contact.errors.full_messages).to include("Date can't be prior to 01/01/1989.")
    end

    it "validates want_driving_reimbursement can be true when miles_driven is positive" do
      case_contact.want_driving_reimbursement = true
      case_contact.miles_driven = 1
      expect(case_contact).to be_valid
    end

    it "validates want_driving_reimbursement cannot be true when miles_driven is nil" do
      case_contact.want_driving_reimbursement = true
      case_contact.miles_driven = nil
      expect(case_contact).not_to be_valid
      expect(case_contact.errors[:base]).to eq(["Must enter miles driven to receive driving reimbursement."])
    end

    it "validates want_driving_reimbursement cannot be true when miles_driven is not positive" do
      case_contact.want_driving_reimbursement = true
      case_contact.miles_driven = 0
      expect(case_contact).not_to be_valid
      expect(case_contact.errors[:base]).to eq(["Must enter miles driven to receive driving reimbursement."])
    end

    it "validates that contact_made cannot be null" do
      case_contact.contact_made = nil
      expect(case_contact).not_to be_valid
      expect(case_contact.errors.full_messages).to include("Contact made must be true or false")
    end

    it "can be updated even if it is old" do
      # case_contact = build_stubbed(:case_contact)
      case_contact.occurred_at = 1.year.ago
      expect(case_contact).to be_valid
    end

    it "can be updated for 30 days after end of quarter" do
      expect(build_stubbed(:case_contact, occurred_at: 4.months.ago + 1.day)).to be_valid
    end
  end

  context "status is started" do
    subject(:case_contact) { build_stubbed :case_contact, :started_status, want_driving_reimbursement: true }

    it "ignores some validations" do
      # case_contact = build_stubbed(:case_contact, :started_status, want_driving_reimbursement: true)
      expect(case_contact.casa_case).to be_nil
      expect(case_contact.medium_type).to be_nil
      expect(case_contact.draft_case_ids).to eq []
      expect(case_contact.occurred_at).to be_nil
      expect(case_contact.miles_driven).to be 0
      expect(case_contact.volunteer_address).to be_nil
      expect(case_contact).to be_valid
    end
  end

  context "status is details" do
    subject(:case_contact) { build_stubbed :case_contact, :details_status, want_driving_reimbursement: true }

    it "ignores some validations" do
      case_contact = build_stubbed(:case_contact, :details_status)
      expect(case_contact.casa_case).to be_nil
      expect(case_contact).to be_valid
    end

    it "requires medium type" do
      case_contact = build_stubbed(:case_contact, :details_status, medium_type: nil)
      expect(case_contact).not_to be_valid
      expect(case_contact.errors.full_messages).to include("Medium type can't be blank")
    end

    it "requires a case to be selected (in draft_case_ids)" do
      case_contact = build_stubbed(:case_contact, :details_status, draft_case_ids: [])
      expect(case_contact).not_to be_valid
      expect(case_contact.errors.full_messages).to include("CASA Case must be selected")
    end

    it "requires occurred at" do
      case_contact = build_stubbed(:case_contact, :details_status, occurred_at: nil)
      expect(case_contact).not_to be_valid
      expect(case_contact.errors[:occurred_at]).to eq(["can't be blank"])
      expect(case_contact.errors.full_messages).to include("Date can't be blank")
    end

    it "requires duration minutes" do
      obj = build_stubbed(:case_contact, :details_status, duration_minutes: nil)
      expect(obj).not_to be_valid
      expect(obj.errors.full_messages).to include("Duration minutes can't be blank")
    end

    it "validates miles driven if want reimbursement" do
      obj = build_stubbed(:case_contact, :details_status, want_driving_reimbursement: true)
      expect(obj).not_to be_valid
      expect(obj.errors.full_messages).to include("Must enter miles driven to receive driving reimbursement.")
    end
  end

  describe "#update_cleaning_contact_types" do
    it "cleans up contact types before saving" do
      group = build_stubbed(:contact_type_group)
      type1 = build(:contact_type, contact_type_group: group)
      type2 = create(:contact_type, contact_type_group: group)

      case_contact = create(:case_contact, contact_types: [type1])

      expect(case_contact.case_contact_contact_types.count).to be 1
      expect(case_contact.contact_types).to contain_exactly(type1)

      case_contact.update_cleaning_contact_types(contact_type_ids: [type2.id])

      expect(case_contact.case_contact_contact_types.count).to eq 1
      expect(case_contact.contact_types.reload).to contain_exactly(type2)
    end
  end

  describe "scopes" do
    describe "date related scopes" do
      let!(:case_contacts) do
        [
          create(:case_contact, occurred_at: Time.zone.yesterday - 1),
          create(:case_contact, occurred_at: Time.zone.yesterday),
          create(:case_contact, occurred_at: Time.zone.today)
        ]
      end

      let(:date) { Time.zone.yesterday }

      describe ".occurred_starting_at" do
        subject(:occurred_starting_at) { described_class.occurred_starting_at(date) }

        context "with specified date" do
          it { is_expected.to contain_exactly(case_contacts.second, case_contacts.third) }
        end

        context "with no specified date" do
          let(:date) { nil }

          it { is_expected.to match_array(case_contacts) }
        end
      end

      describe ".occurred_ending_at" do
        subject(:occurred_ending_at) { described_class.occurred_ending_at(date) }

        context "with specified date" do
          it { is_expected.to contain_exactly(case_contacts.first, case_contacts.second) }
        end

        context "with no specified date" do
          let(:date) { nil }

          it { is_expected.to match_array(case_contacts) }
        end
      end
    end

    describe ".contact_type" do
      subject(:contact_type) { described_class.contact_type([youth_type.id, supervisor_type.id]) }

      let(:group) { build(:contact_type_group) }
      let(:youth_type) { build(:contact_type, name: "Youth", contact_type_group: group) }
      let(:supervisor_type) { build(:contact_type, name: "Supervisor", contact_type_group: group) }
      let(:parent_type) { build(:contact_type, name: "Parent", contact_type_group: group) }

      let!(:case_contacts_to_match) do
        [
          create(:case_contact, contact_types: [youth_type, supervisor_type]),
          create(:case_contact, contact_types: [supervisor_type]),
          create(:case_contact, contact_types: [youth_type, parent_type])
        ]
      end

      let!(:other_case_contact) { build_stubbed(:case_contact, contact_types: [parent_type]) }

      it { is_expected.to match_array(case_contacts_to_match) }
    end

    describe ".contact_made" do
      subject { described_class.contact_made(contact_made) }

      let!(:false_contact) { create :case_contact, contact_made: false }
      let!(:true_contact) { create :case_contact, contact_made: true }

      context "with arg niether true/false (empty string)" do
        let(:contact_made) { "" }

        it "returns case contacts filtered by contact made option" do
          expect(subject).to contain_exactly(false_contact, true_contact)
        end
      end

      context "with true arg" do
        let(:contact_made) { true }

        it "returns case contacts filtered by contact made option" do
          expect(subject).to contain_exactly(true_contact)
          expect(subject).not_to include(false_contact)
        end
      end

      context "with false arg" do
        let(:contact_made) { false }

        it "returns case contacts filtered by contact made option" do
          expect(subject).to contain_exactly(false_contact)
          expect(subject).not_to include(true_contact)
        end
      end
    end

    describe ".has_transitioned" do
      subject { described_class.has_transitioned argument }

      let(:age) { 14 }
      let(:casa_org) { create :casa_org }
      let(:pre_transition_case) { create :casa_case, birth_month_year_youth: 10.years.ago, casa_org: }
      let!(:pre_transition_contact) { create :case_contact, casa_case: pre_transition_case }
      let(:post_transition_case) { create :casa_case, birth_month_year_youth: 15.years.ago, casa_org: }
      let!(:post_transition_contact) { create :case_contact, casa_case: post_transition_case }

      context "when argument is neither true/false (empty string)" do
        let(:argument) { "" }

        it "returns all case contacts" do
          expect(subject).to contain_exactly(pre_transition_contact, post_transition_contact)
        end
      end

      context "with true option" do
        let(:argument) { true }

        it "returns case contacts with transition aged youth" do
          expect(subject).to contain_exactly(post_transition_contact)
          expect(subject).not_to include pre_transition_contact
        end
      end

      context "with false option" do
        let(:argument) { false }

        it "returns case contacts without pre-transition aged youth" do
          expect(subject).to contain_exactly(pre_transition_contact)
          expect(subject).not_to include post_transition_contact
        end
      end
    end

    describe ".want_driving_reimbursement" do
      context "with both option" do
        it "returns case contacts filtered by contact made option" do
          case_contact_1 = create(:case_contact, {miles_driven: 50, want_driving_reimbursement: true})
          case_contact_2 = create(:case_contact, {miles_driven: 50, want_driving_reimbursement: false})

          expect(described_class.want_driving_reimbursement("")).to contain_exactly(case_contact_1, case_contact_2)
        end
      end

      context "with yes option" do
        it "returns case contacts filtered by contact made option" do
          case_contact = create(:case_contact, {miles_driven: 50, want_driving_reimbursement: true})
          build_stubbed(:case_contact, miles_driven: 50, want_driving_reimbursement: false)

          expect(described_class.want_driving_reimbursement(true)).to contain_exactly(case_contact)
        end
      end

      context "with no option" do
        it "returns case contacts filtered by contact made option" do
          build_stubbed(:case_contact, miles_driven: 50, want_driving_reimbursement: true)
          case_contact = create(:case_contact, miles_driven: 50, want_driving_reimbursement: false)

          expect(described_class.want_driving_reimbursement(false)).to contain_exactly(case_contact)
        end
      end
    end

    describe ".contact_medium" do
      subject(:contact_medium) { described_class.contact_medium(medium_type) }

      let!(:case_contacts) do
        [
          create(:case_contact, medium_type: "in-person"),
          create(:case_contact, medium_type: "letter")
        ]
      end

      describe "with specified medium parameter" do
        let(:medium_type) { "in-person" }

        it { is_expected.to contain_exactly case_contacts.first }
      end

      describe "without specified medium parameter" do
        let(:medium_type) { nil }

        it { is_expected.to match_array(case_contacts) }
      end
    end

    describe ".sorted_by" do
      subject(:sorted_by) { described_class.sorted_by(sort_option) }

      context "without sort option" do
        let(:sort_option) { nil }

        it { expect { sorted_by }.to raise_error(ArgumentError, "Invalid sort option: nil") }
      end

      context "with invalid sort option" do
        let(:sort_option) { "1254645" }

        it { expect { sorted_by }.to raise_error(ArgumentError, "Invalid sort option: \"1254645\"") }
      end

      context "with valid sort option" do
        context "with occurred_at option" do
          let(:sort_option) { "occurred_at_#{direction}" }

          let!(:case_contacts) do
            [
              create(:case_contact, occurred_at: Time.zone.today - 3),
              create(:case_contact, occurred_at: Time.zone.today - 1),
              create(:case_contact, occurred_at: Time.zone.today - 2)
            ]
          end

          context "when sorting by ascending order" do
            let(:direction) { "asc" }

            it { is_expected.to contain_exactly(case_contacts[0], case_contacts[2], case_contacts[1]) }
          end

          context "when sorting by descending order" do
            let(:direction) { "desc" }

            it { is_expected.to contain_exactly(case_contacts[1], case_contacts[2], case_contacts[0]) }
          end
        end

        context "with contact_type option" do
          let(:sort_option) { "contact_type_#{direction}" }

          let(:group) { create(:contact_type_group) }

          let(:contact_types) do
            [
              create(:contact_type, name: "Supervisor", contact_type_group: group),
              create(:contact_type, name: "Parent", contact_type_group: group),
              create(:contact_type, name: "Youth", contact_type_group: group)
            ]
          end

          let!(:case_contacts) do
            contact_types.map do |contact_type|
              create(:case_contact, contact_types: [contact_type])
            end
          end

          context "when sorting by ascending order" do
            let(:direction) { "asc" }

            it { is_expected.to contain_exactly(case_contacts[1], case_contacts[0], case_contacts[2]) }
          end

          context "when sorting by descending order" do
            let(:direction) { "desc" }

            it { is_expected.to contain_exactly(case_contacts[2], case_contacts[0], case_contacts[1]) }
          end
        end

        context "with medium_type option" do
          let(:sort_option) { "contact_type_#{direction}" }

          let!(:case_contacts) do
            [
              create(:case_contact, medium_type: "in-person"),
              create(:case_contact, medium_type: "text/email"),
              create(:case_contact, medium_type: "letter")
            ]
          end

          context "when sorting by ascending order" do
            let(:direction) { "asc" }

            it { is_expected.to contain_exactly(case_contacts[0], case_contacts[2], case_contacts[1]) }
          end

          context "when sorting by descending order" do
            let(:direction) { "desc" }

            it { is_expected.to contain_exactly(case_contacts[1], case_contacts[2], case_contacts[0]) }
          end
        end

        context "with want_driving_reimbursement option" do
          let(:sort_option) { "want_driving_reimbursement_#{direction}" }

          let!(:case_contacts) do
            [
              create(:case_contact, miles_driven: 1, want_driving_reimbursement: true),
              create(:case_contact, miles_driven: 1, want_driving_reimbursement: false)
            ]
          end

          context "when sorting by ascending order" do
            let(:direction) { "asc" }

            it { is_expected.to contain_exactly(case_contacts[0], case_contacts[1]) }
          end

          context "when sorting by descending order" do
            let(:direction) { "desc" }

            it { is_expected.to contain_exactly(case_contacts[1], case_contacts[0]) }
          end
        end

        context "with contact_made option" do
          let(:sort_option) { "contact_made_#{direction}" }

          let!(:case_contacts) do
            [
              create(:case_contact, contact_made: true),
              create(:case_contact, contact_made: false)
            ]
          end

          context "when sorting by ascending order" do
            let(:direction) { "asc" }

            it { is_expected.to contain_exactly(case_contacts[1], case_contacts[0]) }
          end

          context "when sorting by descending order" do
            let(:direction) { "desc" }

            it { is_expected.to contain_exactly(case_contacts[0], case_contacts[1]) }
          end
        end
      end
    end

    describe ".with_casa_case" do
      let!(:casa_case) { create(:casa_case) }
      let!(:case_contacts) { create_list(:case_contact, 3, casa_case: casa_case) }

      before { create_list(:case_contact, 3) }

      context "when parameter is nil" do
        it "returns all casa cases" do
          expect(described_class.with_casa_case(nil)).to eq(described_class.all)
        end
      end

      context "when parameter is not nil" do
        it "returns contacts with the given casa case ids" do
          expect(described_class.with_casa_case(casa_case.id)).to match_array(case_contacts)
        end
      end
    end

    describe ".used_create_another" do
      subject { described_class.used_create_another }

      let!(:scope_case_contact) { create(:case_contact, metadata: {"create_another" => true}) }
      let!(:false_case_contact) { create(:case_contact, metadata: {"create_another" => false}) }
      let!(:empty_meta_case_contact) { create(:case_contact) }

      it "returns only the case contacts with the metadata key 'create_another' set to true" do
        expect(subject).to include(scope_case_contact)
        expect(subject).not_to include(false_case_contact)
        expect(subject).not_to include(empty_meta_case_contact)
      end
    end
  end

  describe "#contact_groups_with_types" do
    it "returns the groups with their associated case types" do
      group1 = build(:contact_type_group, name: "Family")
      group2 = build(:contact_type_group, name: "Health")
      contact_type1 = build(:contact_type, contact_type_group: group1, name: "Parent")
      contact_type2 = build(:contact_type, contact_type_group: group2, name: "Medical Professional")
      contact_type3 = build(:contact_type, contact_type_group: group2, name: "Other Therapist")
      case_contact_types = [contact_type1, contact_type2, contact_type3]
      case_contact = create(:case_contact)
      case_contact.contact_types = case_contact_types

      groups_with_types = case_contact.contact_groups_with_types

      expect(groups_with_types.keys).to contain_exactly("Family", "Health")
      expect(groups_with_types["Family"]).to contain_exactly("Parent")
      expect(groups_with_types["Health"]).to contain_exactly("Medical Professional", "Other Therapist")
    end
  end

  describe "#requested_followup" do
    context "no followup exists in requested status" do
      it "returns nil" do
        case_contact = build_stubbed(:case_contact)
        expect(case_contact.requested_followup).to be_nil
      end
    end

    context "a followup exists in requested status" do
      it "returns nil" do
        case_contact = build_stubbed(:case_contact)
        followup = create(:followup, case_contact: case_contact)

        expect(case_contact.requested_followup).to eq(followup)
      end
    end
  end

  describe "reimbursement amount" do
    let(:case_contact) { build(:case_contact, :wants_reimbursement) }

    describe "when casa org has nil mileage_rate_for_given_date" do
      it "is nil" do
        expect(case_contact.casa_case.casa_org.mileage_rate_for_given_date(case_contact.occurred_at.to_datetime)).to be_nil
        expect(case_contact.reimbursement_amount).to be_nil
      end
    end

    describe "when casa org has value for mileage_rate_for_given_date" do
      let!(:mileage_rate) { create(:mileage_rate, casa_org: case_contact.casa_case.casa_org, effective_date: 3.days.ago, amount: 5.50) }

      it "is multiple of miles driven and mileage rate" do
        expect(case_contact.reimbursement_amount).to eq 2508
      end
    end
  end

  describe "#should_send_reimbursement_email?" do
    let(:supervisor) { create(:supervisor, receive_reimbursement_email: true) }
    let(:volunteer) { create(:volunteer, supervisor: supervisor) }
    let(:casa_case) { create(:casa_case) }
    let(:case_contact) { build(:case_contact, :wants_reimbursement, casa_case: casa_case, creator: volunteer) }

    it "returns true if wants reimbursement, reimbursement changed, and has active supervisor" do
      expect(case_contact.want_driving_reimbursement_changed?).to be true
      expect(case_contact.should_send_reimbursement_email?).to be true
    end

    it "returns false if doesn't want reimbursement" do
      case_contact.want_driving_reimbursement = false
      expect(case_contact.should_send_reimbursement_email?).to be false
    end

    it "returns false if creator doesn't have supervisor" do
      volunteer.supervisor_volunteer = nil
      expect(case_contact.supervisor.blank?).to be true
      expect(case_contact.should_send_reimbursement_email?).to be false
    end

    it "returns false if creator's supervisor is inactive" do
      supervisor.update!(active: false)
      expect(case_contact.should_send_reimbursement_email?).to be false
    end
  end

  describe "volunteer assignment" do
    let(:casa_org) { create(:casa_org) }
    let(:admin) { create(:casa_admin, casa_org:) }
    let(:supervisor) { create(:supervisor, casa_org:) }
    let(:volunteer) { create(:volunteer, supervisor:, casa_org:) }
    let(:casa_case) { create(:casa_case, casa_org:) }
    let(:case_contact) { build(:case_contact, casa_case: casa_case, creator: creator) }

    context "when creator is volunteer" do
      let(:creator) { volunteer }

      it "creator is the volunteer" do
        expect(case_contact.volunteer).to eq volunteer
      end

      it "enables address field" do
        expect(case_contact.address_field_disabled?).to be false
      end
    end

    context "when creator is admin" do
      let(:creator) { admin }

      context "when casa case has one volunteer assigned" do
        let!(:contact_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }

        it "volunteer is the assigned volunteer" do
          expect(case_contact.volunteer).to eq volunteer
        end

        it "enables address field" do
          expect(case_contact.address_field_disabled?).to be false
        end
      end

      context "when casa case has no volunteers assigned" do
        it "volunteer is nil" do
          expect(case_contact.volunteer).to be_nil
        end

        it "disbales address field" do
          expect(case_contact.address_field_disabled?).to be true
        end
      end

      context "when casa case has more than 1 volunteer assigned" do
        let(:other_volunteer) { create(:volunteer, casa_org: casa_org) }
        let!(:contact_assignments) {
          [
            create(:case_assignment, volunteer: volunteer, casa_case: casa_case),
            create(:case_assignment, volunteer: other_volunteer, casa_case: casa_case)
          ]
        }

        it "volunteer is nil" do
          expect(case_contact.volunteer).to be_nil
        end

        it "disbales address field" do
          expect(case_contact.address_field_disabled?).to be true
        end
      end
    end
  end
end

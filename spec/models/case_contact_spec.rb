require "rails_helper"

RSpec.describe CaseContact, type: :model do
  it { should have_many(:contact_topic_answers).dependent(:destroy) }
  it { is_expected.to validate_numericality_of(:miles_driven).is_less_than 10_000 }
  it { is_expected.to validate_numericality_of(:miles_driven).is_greater_than_or_equal_to 0 }

  context "status is active" do
    it "belongs to a creator" do
      case_contact = build_stubbed(:case_contact, creator: nil)
      expect(case_contact).to_not be_valid
      expect(case_contact.errors[:creator]).to eq(["must exist"])
    end

    it "belongs to a casa case" do
      case_contact = build_stubbed(:case_contact, casa_case: nil)
      expect(case_contact).to_not be_valid
      expect(case_contact.errors[:casa_case_id]).to eq(["can't be blank"])
    end

    it "defaults miles_driven to zero" do
      case_contact = build_stubbed(:case_contact)
      expect(case_contact.miles_driven).to eq 0
    end

    it "validates presence of occurred_at" do
      case_contact = build(:case_contact, occurred_at: nil)
      expect(case_contact).to_not be_valid
      expect(case_contact.errors[:occurred_at]).to eq(["can't be blank"])
    end

    it "validates duration_minutes can be less than 15 minutes." do
      case_contact = build_stubbed(:case_contact, duration_minutes: 10)
      expect(case_contact).to be_valid
    end

    it "verifies occurred at is not in the future" do
      case_contact = build_stubbed(:case_contact, occurred_at: Time.now + 1.week)
      expect(case_contact).to_not be_valid
      expect(case_contact.errors[:occurred_at]).to eq(["can't be in the future"])
      expect(case_contact.errors.full_messages).to include("Date can't be in the future")
    end

    it "verifies occurred at is not before 1/1/1989" do
      case_contact = build_stubbed(:case_contact, occurred_at: "1984-01-01".to_date)
      expect(case_contact).to_not be_valid
      expect(case_contact.errors[:occurred_at]).to eq(["can't be prior to 01/01/1989."])
      expect(case_contact.errors.full_messages).to include("Date can't be prior to 01/01/1989.")
    end

    it "validates want_driving_reimbursement can be true when miles_driven is  positive" do
      case_contact = build_stubbed(:case_contact, want_driving_reimbursement: true, miles_driven: 1)
      expect(case_contact).to be_valid
    end

    it "validates want_driving_reimbursement cannot be true when miles_driven is nil" do
      case_contact = build_stubbed(:case_contact, want_driving_reimbursement: true, miles_driven: nil)
      expect(case_contact).not_to be_valid
      expect(case_contact.errors[:base]).to eq(["Must enter miles driven to receive driving reimbursement."])
    end

    it "validates want_driving_reimbursement cannot be true when miles_driven is not positive" do
      case_contact = build_stubbed(:case_contact, want_driving_reimbursement: true, miles_driven: 0)
      expect(case_contact).not_to be_valid
      expect(case_contact.errors[:base]).to eq(["Must enter miles driven to receive driving reimbursement."])
    end

    it "validates that contact_made cannot be null" do
      case_contact = build_stubbed(:case_contact, contact_made: nil)
      expect(case_contact).not_to be_valid
      expect(case_contact.errors[:base]).to eq(["Must enter whether the contact was made."])
    end

    it "can be updated even if it is old" do
      case_contact = build_stubbed(:case_contact)
      case_contact.occurred_at = Time.zone.now - 1.year
      expect(case_contact).to be_valid
    end

    it "can be updated for 30 days after end of quarter" do
      expect(build_stubbed(:case_contact, occurred_at: Time.zone.now - 4.months + 1.day)).to be_valid
    end
  end

  context "status is started" do
    it "ignores some validations" do
      case_contact = build_stubbed(:case_contact, :started_status, want_driving_reimbursement: true)
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
    it "ignores some validations" do
      case_contact = build_stubbed(:case_contact, :details_status, want_driving_reimbursement: true)
      expect(case_contact.casa_case).to be nil
      expect(case_contact.miles_driven).to be 0
      expect(case_contact.volunteer_address).to be_nil
      expect(case_contact).to be_valid
    end

    it "requires medium type" do
      case_contact = build_stubbed(:case_contact, :details_status, medium_type: nil)
      expect(case_contact).not_to be_valid
      expect(case_contact.errors.full_messages).to include("Medium type can't be blank")
    end

    it "requires a case to be selected" do
      case_contact = build_stubbed(:case_contact, :details_status, draft_case_ids: [])
      expect(case_contact).not_to be_valid
      expect(case_contact.errors.full_messages).to include("You must select at least one casa case.")
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
  end

  context "status is expenses" do
    it "validates miles driven if want reimbursement" do
      obj = build_stubbed(:case_contact, :expenses_status, want_driving_reimbursement: true)
      expect(obj).not_to be_valid
      expect(obj.errors.full_messages).to include("Must enter miles driven to receive driving reimbursement.")
    end

    it "requires a case to be selected" do
      obj = build_stubbed(:case_contact, :expenses_status, :wants_reimbursement, draft_case_ids: [])
      expect(obj).not_to be_valid
      expect(obj.errors.full_messages).to include("You must select at least one casa case.")
    end
  end

  describe "#update_cleaning_contact_types" do
    it "cleans up contact types before saving" do
      group = build_stubbed(:contact_type_group)
      type1 = build(:contact_type, contact_type_group: group)
      type2 = create(:contact_type, contact_type_group: group)

      case_contact = create(:case_contact, contact_types: [type1])

      expect(case_contact.case_contact_contact_types.count).to be 1
      expect(case_contact.contact_types).to match_array([type1])

      case_contact.update_cleaning_contact_types(contact_type_ids: [type2.id])

      expect(case_contact.case_contact_contact_types.count).to eq 1
      expect(case_contact.contact_types.reload).to match_array([type2])
    end
  end

  describe "#create_with_answers" do
    let(:contact_topics) {
      [
        build(:contact_topic, active: true, soft_delete: false),
        build(:contact_topic, active: false, soft_delete: false),
        build(:contact_topic, active: true, soft_delete: true),
        build(:contact_topic, active: false, soft_delete: true)
      ]
    }
    let(:org) { create(:casa_org, contact_topics:) }
    let(:admin) { create(:casa_admin, casa_org: org) }
    let(:casa_case) { create(:casa_case, casa_org: org) }

    context "when creation is successful" do
      it "create a case_contact" do
        org
        expect {
          CaseContact.create_with_answers(org, creator: admin)
        }.to change(CaseContact, :count).from(0).to(1)
      end

      it "creates only active and non-deleted contact_topic_answers" do
        org
        expect {
          CaseContact.create_with_answers(org, creator: admin)
        }.to change(ContactTopicAnswer, :count).from(0).to(1)

        case_contact = CaseContact.last
        topics = case_contact.contact_topic_answers.map(&:contact_topic)

        expect(topics).to include(contact_topics.first)
      end
    end

    context "when a topic answer creation fails" do
      it "does not create a case contact" do
        expect {
          CaseContact.create_with_answers(org)
        }.to_not change(CaseContact, :count)
      end

      it "adds errors from contact_topic_answers" do
        allow(org.contact_topics).to receive(:active).and_return([nil])
        result = CaseContact.create_with_answers(org, creator: admin)
        expect(result.errors[:contact_topic_answers]).to include("could not create topic nil")
      end
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
          it { is_expected.to match_array([case_contacts.second, case_contacts.third]) }
        end

        context "with no specified date" do
          let(:date) { nil }

          it { is_expected.to match_array(case_contacts) }
        end
      end

      describe ".occurred_ending_at" do
        subject(:occurred_ending_at) { described_class.occurred_ending_at(date) }

        context "with specified date" do
          it { is_expected.to match_array([case_contacts.first, case_contacts.second]) }
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
      context "with both option" do
        it "returns case contacts filtered by contact made option" do
          case_contact_1 = create(:case_contact, contact_made: false)
          case_contact_2 = create(:case_contact, contact_made: true)

          expect(CaseContact.contact_made("")).to match_array([case_contact_1, case_contact_2])
        end
      end

      context "with yes option" do
        it "returns case contacts filtered by contact made option" do
          case_contact = create(:case_contact, contact_made: true)
          build_stubbed(:case_contact, contact_made: false)

          expect(CaseContact.contact_made(true)).to match_array([case_contact])
        end
      end

      context "with no option" do
        it "returns case contacts filtered by contact made option" do
          case_contact = create(:case_contact, contact_made: false)
          build_stubbed(:case_contact, contact_made: true)

          expect(CaseContact.contact_made(false)).to match_array([case_contact])
        end
      end
    end

    describe ".has_transitioned" do
      let(:casa_case_1) { create(:casa_case, birth_month_year_youth: 15.years.ago) }
      let(:casa_case_2) { create(:casa_case, birth_month_year_youth: 10.years.ago) }

      context "with both option" do
        let!(:case_contact_1) { create(:case_contact, {casa_case: casa_case_1}) }
        let!(:case_contact_2) { create(:case_contact, {casa_case: casa_case_2}) }

        it "returns case contacts filtered by contact made option" do
          expect(described_class.has_transitioned).to match_array(
            [case_contact_1, case_contact_2]
          )
        end
      end

      context "with true option" do
        let!(:case_contact_1) { create(:case_contact, {casa_case: casa_case_1}) }
        let!(:case_contact_2) { create(:case_contact, {casa_case: casa_case_2}) }

        it "returns case contacts filtered by contact made option" do
          expect(described_class.has_transitioned(true)).to match_array([case_contact_1])
        end
      end

      context "with false option" do
        let!(:case_contact_1) { create(:case_contact, {casa_case: casa_case_1}) }
        let!(:case_contact_2) { create(:case_contact, {casa_case: casa_case_2}) }

        it "returns case contacts filtered by contact made option" do
          expect(described_class.has_transitioned(false)).to match_array([case_contact_2])
        end
      end
    end

    describe ".want_driving_reimbursement" do
      context "with both option" do
        it "returns case contacts filtered by contact made option" do
          case_contact_1 = create(:case_contact, {miles_driven: 50, want_driving_reimbursement: true})
          case_contact_2 = create(:case_contact, {miles_driven: 50, want_driving_reimbursement: false})

          expect(CaseContact.want_driving_reimbursement("")).to match_array([case_contact_1, case_contact_2])
        end
      end

      context "with yes option" do
        it "returns case contacts filtered by contact made option" do
          case_contact = create(:case_contact, {miles_driven: 50, want_driving_reimbursement: true})
          build_stubbed(:case_contact, {miles_driven: 50, want_driving_reimbursement: false})

          expect(CaseContact.want_driving_reimbursement(true)).to match_array([case_contact])
        end
      end

      context "with no option" do
        it "returns case contacts filtered by contact made option" do
          build_stubbed(:case_contact, {miles_driven: 50, want_driving_reimbursement: true})
          case_contact = create(:case_contact, {miles_driven: 50, want_driving_reimbursement: false})

          expect(CaseContact.want_driving_reimbursement(false)).to match_array([case_contact])
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

            it { is_expected.to match_array [case_contacts[0], case_contacts[2], case_contacts[1]] }
          end

          context "when sorting by descending order" do
            let(:direction) { "desc" }

            it { is_expected.to match_array [case_contacts[1], case_contacts[2], case_contacts[0]] }
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

            it { is_expected.to match_array [case_contacts[1], case_contacts[0], case_contacts[2]] }
          end

          context "when sorting by descending order" do
            let(:direction) { "desc" }

            it { is_expected.to match_array [case_contacts[2], case_contacts[0], case_contacts[1]] }
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

            it { is_expected.to match_array [case_contacts[0], case_contacts[2], case_contacts[1]] }
          end

          context "when sorting by descending order" do
            let(:direction) { "desc" }

            it { is_expected.to match_array [case_contacts[1], case_contacts[2], case_contacts[0]] }
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

            it { is_expected.to match_array [case_contacts[0], case_contacts[1]] }
          end

          context "when sorting by descending order" do
            let(:direction) { "desc" }

            it { is_expected.to match_array [case_contacts[1], case_contacts[0]] }
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

            it { is_expected.to match_array [case_contacts[1], case_contacts[0]] }
          end

          context "when sorting by descending order" do
            let(:direction) { "desc" }

            it { is_expected.to match_array [case_contacts[0], case_contacts[1]] }
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
          expect(described_class.with_casa_case(nil)).to eq(CaseContact.all)
        end
      end

      context "when parameter is not nil" do
        it "returns contacts with the given casa case ids" do
          expect(described_class.with_casa_case(casa_case.id)).to match_array(case_contacts)
        end
      end
    end

    describe ".used_create_another" do
      let!(:scope_case_contact) { create(:case_contact, metadata: {"create_another" => true}) }
      let!(:false_case_contact) { create(:case_contact, metadata: {"create_another" => false}) }
      let!(:empty_meta_case_contact) { create(:case_contact) }

      subject { described_class.used_create_another }

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

      expect(groups_with_types.keys).to match_array(["Family", "Health"])
      expect(groups_with_types["Family"]).to match_array(["Parent"])
      expect(groups_with_types["Health"]).to match_array(["Medical Professional", "Other Therapist"])
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
      supervisor.update(active: false)
      expect(case_contact.should_send_reimbursement_email?).to be false
    end
  end

  describe "volunteer assignment" do
    let(:casa_org) { create(:casa_org) }
    let(:admin) { create(:casa_admin, casa_org: casa_org) }
    let(:supervisor) { create(:supervisor, casa_org: casa_org) }
    let(:volunteer) { create(:volunteer, supervisor: supervisor, casa_org: casa_org) }
    let(:casa_case) { create(:casa_case, casa_org: casa_org) }
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
          expect(case_contact.volunteer).to be nil
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
          expect(case_contact.volunteer).to be nil
        end

        it "disbales address field" do
          expect(case_contact.address_field_disabled?).to be true
        end
      end
    end
  end
end

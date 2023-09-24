require "rails_helper"

RSpec.describe CaseContact, type: :model do
  it { is_expected.to validate_numericality_of(:miles_driven).is_less_than 10_000 }
  it { is_expected.to validate_numericality_of(:miles_driven).is_greater_than_or_equal_to 0 }

  it "belongs to a creator" do
    case_contact = build_stubbed(:case_contact, creator: nil)
    expect(case_contact).to_not be_valid
    expect(case_contact.errors[:creator]).to eq(["must exist"])
  end

  it "belongs to a casa case" do
    case_contact = build_stubbed(:case_contact, casa_case: nil)
    expect(case_contact).to_not be_valid
    expect(case_contact.errors[:casa_case]).to eq(["must exist"])
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

  it "validates duration_minutes is only numeric values" do
    case_contact = build_stubbed(:case_contact, duration_minutes: nil)
    expect(case_contact).to_not be_valid
    expect(case_contact.errors[:duration_minutes]).to eq(["Minimum case contact duration should be 15 minutes."])
  end

  it "validates duration_minutes cannot be less than 15 minutes." do
    case_contact = build_stubbed(:case_contact, duration_minutes: 10)
    expect(case_contact).to_not be_valid
    expect(case_contact.errors[:duration_minutes]).to eq(["Minimum case contact duration should be 15 minutes."])
  end

  it "verifies occurred at is not in the future" do
    case_contact = build_stubbed(:case_contact, occurred_at: Time.now + 1.week)
    expect(case_contact).to_not be_valid
    expect(case_contact.errors[:occurred_at]).to eq(["cannot be in the future"])
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
    case_contact = build(:case_contact)
    case_contact.update!(occurred_at: Time.zone.now - 1.year)
    expect(case_contact).to be_valid
  end

  it "can be updated for 30 days after end of quarter" do
    expect(build(:case_contact, occurred_at: Time.zone.now - 4.months + 1.day)).to be_valid
  end

  describe "#update_cleaning_contact_types" do
    it "cleans up contact types before saving" do
      group = build_stubbed(:contact_type_group)
      type1 = build(:contact_type, contact_type_group: group)
      type2 = create(:contact_type, contact_type_group: group)

      case_contact = create(:case_contact, contact_types: [type1])

      expect(case_contact.case_contact_contact_type.count).to be 1
      expect(case_contact.contact_types).to match_array([type1])

      case_contact.update_cleaning_contact_types({case_contact_contact_type_attributes: [{contact_type_id: type2.id}]})

      expect(case_contact.case_contact_contact_type.count).to eq 1
      expect(case_contact.contact_types.reload).to match_array([type2])
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
          expect(described_class.with_casa_case(casa_case.id)).to eq(case_contacts)
        end
      end
    end
  end

  describe "#contact_groups_with_types" do
    it "returns the groups with their associated case types" do
      group1 = build_stubbed(:contact_type_group, name: "Family")
      group2 = build_stubbed(:contact_type_group, name: "Health")
      contact_type1 = build_stubbed(:contact_type, contact_type_group: group1, name: "Parent")
      contact_type2 = build_stubbed(:contact_type, contact_type_group: group2, name: "Medical Professional")
      contact_type3 = build_stubbed(:contact_type, contact_type_group: group2, name: "Other Therapist")
      case_contact_types = [contact_type1, contact_type2, contact_type3]
      case_contact = build_stubbed(:case_contact)
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
end

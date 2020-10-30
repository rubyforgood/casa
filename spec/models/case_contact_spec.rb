require "rails_helper"

RSpec.describe CaseContact, type: :model do
  context "validations" do
    it { is_expected.to validate_numericality_of(:miles_driven).is_less_than 10_000 }
    it { is_expected.to validate_numericality_of(:miles_driven).is_greater_than_or_equal_to 0 }
  end

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

  it "defaults miles_driven to zero" do
    case_contact = create(:case_contact)
    expect(case_contact.miles_driven).to eq 0
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
    expect(case_contact.errors[:base]).to eq(["cannot edit case contacts created before the current quarter"])
  end

  describe "#update_cleaning_contact_types" do
    it "cleans up contact types before saving" do
      group = create(:contact_type_group)
      type1 = create(:contact_type, contact_type_group: group)
      type2 = create(:contact_type, contact_type_group: group)

      case_contact = create(:case_contact, contact_types: [type1])

      expect(case_contact.case_contact_contact_type.count).to be 1
      expect(case_contact.contact_types).to match_array([type1])

      case_contact.update_cleaning_contact_types({case_contact_contact_type_attributes: [{contact_type_id: type2.id}]})

      expect(case_contact.case_contact_contact_type.count).to be 1
      expect(case_contact.contact_types.reload).to match_array([type2])
    end
  end

  describe "scopes" do
    describe ".contact_type" do
      it "returns case contacts filtered by contact type id" do
        group = create(:contact_type_group)
        youth_type = create(:contact_type, name: "Youth", contact_type_group: group)
        supervisor_type = create(:contact_type, name: "Supervisor", contact_type_group: group)
        parent_type = create(:contact_type, name: "Parent", contact_type_group: group)

        case_contacts_to_match = [
          create(:case_contact, contact_types: [youth_type, supervisor_type]),
          create(:case_contact, contact_types: [supervisor_type]),
          create(:case_contact, contact_types: [youth_type, parent_type])
        ]
        create(:case_contact, contact_types: [parent_type])

        expect(CaseContact.contact_type([youth_type.id, supervisor_type.id])).to match_array(case_contacts_to_match)
      end
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
          create(:case_contact, contact_made: false)

          expect(CaseContact.contact_made(true)).to match_array([case_contact])
        end
      end

      context "with no option" do
        it "returns case contacts filtered by contact made option" do
          case_contact = create(:case_contact, contact_made: false)
          create(:case_contact, contact_made: true)

          expect(CaseContact.contact_made(false)).to match_array([case_contact])
        end
      end
    end

    describe ".has_transitioned" do
      context "with both option" do
        it "returns case contacts filtered by contact made option" do
          case_case_1 = create(:casa_case, transition_aged_youth: true)
          case_case_2 = create(:casa_case, transition_aged_youth: false)
          case_contact_1 = create(:case_contact, {casa_case: case_case_1})
          case_contact_2 = create(:case_contact, {casa_case: case_case_2})

          expect(CaseContact.has_transitioned("")).to match_array([case_contact_1, case_contact_2])
        end
      end

      context "with yes option" do
        it "returns case contacts filtered by contact made option" do
          case_case_1 = create(:casa_case, transition_aged_youth: true)
          case_case_2 = create(:casa_case, transition_aged_youth: false)
          case_contact = create(:case_contact, {casa_case: case_case_1})
          create(:case_contact, {casa_case: case_case_2})

          expect(CaseContact.has_transitioned(true)).to match_array([case_contact])
        end
      end

      context "with no option" do
        it "returns case contacts filtered by contact made option" do
          case_case_1 = create(:casa_case, transition_aged_youth: true)
          case_case_2 = create(:casa_case, transition_aged_youth: false)
          create(:case_contact, {casa_case: case_case_1})
          case_contact = create(:case_contact, {casa_case: case_case_2})

          expect(CaseContact.has_transitioned(false)).to match_array([case_contact])
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
          create(:case_contact, {miles_driven: 50, want_driving_reimbursement: false})

          expect(CaseContact.want_driving_reimbursement(true)).to match_array([case_contact])
        end
      end

      context "with no option" do
        it "returns case contacts filtered by contact made option" do
          create(:case_contact, {miles_driven: 50, want_driving_reimbursement: true})
          case_contact = create(:case_contact, {miles_driven: 50, want_driving_reimbursement: false})

          expect(CaseContact.want_driving_reimbursement(false)).to match_array([case_contact])
        end
      end
    end
  end
end

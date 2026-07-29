require "rails_helper"

RSpec.describe AdditionalExpense, type: :model do
  it { is_expected.to belong_to(:case_contact) }
  it { is_expected.to have_one(:casa_case).through(:case_contact) }
  it { is_expected.to have_one(:casa_org).through(:case_contact) }
  it { is_expected.to have_one(:contact_creator).through(:case_contact) }
  it { is_expected.to have_one(:contact_creator_casa_org).through(:contact_creator) }

  describe "validations" do
    context "when the contact is being submitted (details/active)" do
      let(:case_contact) { build_stubbed(:case_contact, status: "active") }

      it "is valid with a positive amount and a description" do
        expect(build(:additional_expense, amount: 20, describe: "meal", case_contact:)).to be_valid
      end

      it "requires a positive amount" do
        blank = build(:additional_expense, amount: nil, describe: "meal", case_contact:)
        expect(blank).to be_invalid
        expect(blank.errors[:other_expense_amount]).to include("can't be blank")

        zero = build(:additional_expense, amount: 0, describe: "meal", case_contact:)
        expect(zero).to be_invalid
        expect(zero.errors[:other_expense_amount]).to include("must be greater than 0")
      end

      it "requires a description" do
        expense = build(:additional_expense, amount: 5, describe: nil, case_contact:)
        expect(expense).to be_invalid
        expect(expense.errors[:other_expenses_describe]).to include("can't be blank")
      end

      it "flags both on an empty row -- fill it in or remove it, never silently dropped" do
        empty = build(:additional_expense, amount: nil, describe: nil, case_contact:)
        expect(empty).to be_invalid
        expect(empty.errors[:other_expense_amount]).to include("can't be blank")
        expect(empty.errors[:other_expenses_describe]).to include("can't be blank")
      end
    end

    context "while the contact is still a started draft" do
      let(:case_contact) { build_stubbed(:case_contact, status: "started") }

      it "allows an incomplete row so it can be created then filled" do
        expect(build(:additional_expense, amount: nil, describe: nil, case_contact:)).to be_valid
      end
    end
  end
end

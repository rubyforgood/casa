require "rails_helper"

RSpec.describe AdditionalExpense, type: :model do
  it { is_expected.to belong_to(:case_contact) }
  it { is_expected.to have_one(:casa_case).through(:case_contact) }
  it { is_expected.to have_one(:casa_org).through(:case_contact) }
  it { is_expected.to have_one(:contact_creator).through(:case_contact) }
  it { is_expected.to have_one(:contact_creator_casa_org).through(:contact_creator) }

  describe "validations" do
    let(:case_contact) { build_stubbed :case_contact }

    it "requires describe only if amount is positive" do
      expense = build(:additional_expense, amount: 0, describe: nil, case_contact:)
      expect(expense).to be_valid
      expense.update(amount: 1)
      expect(expense).to be_invalid
    end

    it "requires an amount when a description is given" do
      expense = build(:additional_expense, amount: nil, describe: "coffee", case_contact:)
      expect(expense).to be_invalid
      expect(expense.errors[:other_expense_amount]).to include("can't be blank")
    end
  end
end

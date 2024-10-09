require "rails_helper"

RSpec.describe AdditionalExpense, type: :model do
  it { is_expected.to belong_to(:case_contact) }
  it { is_expected.to have_one(:casa_case).through(:case_contact) }
  it { is_expected.to have_one(:casa_org).through(:case_contact) }
  it { is_expected.to have_one(:contact_creator_casa_org).through(:case_contact) }

  describe "validations" do
    let(:case_contact) { build_stubbed :case_contact }

    it "requires describe only if amount is positive" do
      expense = build(:additional_expense, amount: 0, describe: nil, case_contact:)
      expect(expense).to be_valid
      expense.update(amount: 1)
      expect(expense).to be_invalid
    end
  end
end

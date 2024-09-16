require "rails_helper"

RSpec.describe "CaseContact AdditionalExpenses Form", :flipper, :js, type: :system do
  let(:casa_org) { build :casa_org, :all_reimbursements_enabled }
  let(:volunteer) { create :volunteer, :with_single_case, casa_org: }
  let(:casa_case) { volunteer.casa_cases.first }

  before do
    allow(Flipper).to receive(:enabled?).with(:show_additional_expenses).and_return(true)
    sign_in volunteer
  end

  subject do
    visit new_case_contact_path(casa_case)
    fill_in_contact_details
    fill_in_mileage want_reimbursement: true, miles: 50, address: "123 Params St"
  end

  it "is not rendered when casa org expenses disabled" do
    casa_org.update! additional_expenses_enabled: false

    subject
    check "Request travel or other reimbursement"

    expect(page).to have_no_field(class: "expense-amount-input", visible: :all)
    expect(page).to have_no_field(class: "expense-describe-input", visible: :all)
    expect(page).to have_no_button("Add Expense", visible: :all)
  end

  it "is not shown until Reimbursement is checked and Add Expense clicked" do
    sign_in volunteer
    visit new_case_contact_path casa_case
    fill_in_contact_details

    expect(page).to have_no_button "Add Expense"
    check "Request travel or other reimbursement"
    expect(page).to have_no_field(class: "expense-amount-input", visible: :all)
    expect(page).to have_no_field(class: "expense-describe-input", visible: :all)
    click_on "Add Expense"
    expect(page).to have_field(class: "expense-describe-input")
    expect(page).to have_field(class: "expense-amount-input")
  end

  it "does not submit values if reimbursement is cancelled (unchecked)" do
    subject

    click_on "Add Expense"
    fill_expense_fields 5.34, "Lunch"
    uncheck "Request travel or other reimbursement"

    expect { click_on "Submit" }
      .to change(CaseContact.active, :count).by(1)
      .and not_change(AdditionalExpense, :count)

    case_contact = CaseContact.active.last
    expect(case_contact.additional_expenses).to be_empty
    expect(case_contact.miles_driven).to be_zero
    expect(case_contact.want_driving_reimbursement).to be false
  end

  it "ignores expenses with empty fields" do
    subject

    click_on "Add Expense"
    click_on "Add Expense"
    click_on "Add Expense"
    expect(page).to have_field(class: "expense-describe-input", count: 3, with: nil)
    expect(page).to have_field(class: "expense-amount-input", count: 3, with: "")
    expect { click_on "Submit" }
      .to change(CaseContact.active, :count).by(1)
      .and not_change(AdditionalExpense, :count)
    case_contact = CaseContact.active.last
    expect(case_contact.additional_expenses).to be_empty
  end

  it "can remove an expense" do
    subject
    fill_in_contact_details
    check "Request travel or other reimbursement"
    fill_in "case_contact_miles_driven", with: 50
    fill_in "case_contact_volunteer_address", with: "123 Params St"

    click_on "Add Expense"
    fill_expense_fields 1.50, "1st meal"
    click_on "Add Expense"
    fill_expense_fields 2.50, "2nd meal"
    click_on "Add Expense"
    fill_expense_fields 2.00, "3rd meal"

    within "#contact-form-expenses" do
      click_on "Remove", match: :first
    end

    expect(page).to have_field(class: "expense-amount-input", count: 2)

    expect { click_on "Submit" }
      .to change(CaseContact.active, :count).by(1)
      .and change(AdditionalExpense, :count).by(2)

    case_contact = CaseContact.active.last
    expect(case_contact.additional_expenses.size).to eq(2)
  end

  it "requires a description for each additional expense" do
    subject

    click_on "Add Expense"
    fill_expense_fields 5.34, nil

    expect { click_on "Submit" }
      .to not_change(CaseContact.active, :count)
      .and not_change(AdditionalExpense, :count)

    expect(page).to have_text("Additional expenses is invalid")
    # this is not a great error message!
    expect(page).to have_text("Additional expenses other expenses describe Expense description cannot be blank")
  end

  context "when editing existing case contact expenses" do
    let(:case_contact) { create :case_contact, :wants_reimbursement, casa_case:, creator: volunteer }
    let!(:additional_expenses) do
      [
        create(:additional_expense, case_contact:, other_expense_amount: 1.11, other_expenses_describe: "First Expense"),
        create(:additional_expense, case_contact:, other_expense_amount: 2.22, other_expenses_describe: "Second Expense")
      ]
    end

    subject do
      visit edit_case_contact_path case_contact
    end

    it "shows existing expenses in the form" do
      subject

      expect(page).to have_field(class: "expense-amount-input", count: additional_expenses.size)
      expect(page).to have_field(class: "expense-describe-input", count: additional_expenses.size)
      expect(page).to have_field(class: "expense-amount-input", with: "1.11")
      expect(page).to have_field(class: "expense-describe-input", with: "First Expense")
      expect(page).to have_field(class: "expense-amount-input", with: "2.22")
      expect(page).to have_field(class: "expense-describe-input", with: "Second Expense")
      expect(page).to have_button "Add Expense"
    end

    it "allows removing expenses" do
      subject

      expect(page).to have_css(".expense-amount-input", count: 2)
      expect(page).to have_css(".expense-describe-input", count: 2)

      within "#contact-form-expenses" do
        click_on "Remove", match: :first
      end

      expect(page).to have_css(".expense-amount-input", count: 1)
      expect(page).to have_css(".expense-describe-input", count: 1)

      expect { click_on "Submit" }
        .to not_change(CaseContact.active, :count)
        .and change(AdditionalExpense, :count).by(-1)

      expect(case_contact.reload.additional_expenses.size).to eq(1)
    end

    it "can add an expense" do
      subject

      click_on "Add Expense"
      fill_expense_fields 11.50, "Gas"
      expect { click_on "Submit" }
        .to change(AdditionalExpense, :count).by(1)
      expect(case_contact.reload.additional_expenses.size).to eq(3)
    end
  end
end

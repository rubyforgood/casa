require "rails_helper"

RSpec.describe "additional_expenses", type: :system, flipper: true, js: true do
  let(:casa_org) { build :casa_org, :all_reimbursements_enabled }
  let(:volunteer) { create :volunteer, :with_single_case, casa_org: }
  let(:casa_case) { volunteer.casa_cases.first }

  subject do
    sign_in volunteer
    visit new_case_contact_path(casa_case)
    fill_in_contact_details
  end

  before do
    allow(Flipper).to receive(:enabled?).with(:show_additional_expenses).and_return(true)
  end

  it "additional expenses and notices can be set per organization" do
    other_organization = build(:casa_org)
    other_volunteer = create(:volunteer, casa_org: other_organization)
    other_casa_case = create(:casa_case, casa_org: other_organization)
    create(:case_assignment, casa_case: other_casa_case, volunteer: other_volunteer)

    subject

    expect(page).to have_button "Add Expense"

    sign_in other_volunteer
    visit new_case_contact_path(other_casa_case)
    expect(page).to have_no_button("Add Expense", visible: :all)
  end

  context "when setting additional expenses" do
    it "additional expenses fields appearance" do
      subject

      expect(page).to have_no_field(class: "expense-amount-input")
      expect(page).to have_no_field(class: "expense-describe-input")

      click_on "Add Expense"

      fill_expense_fields 5.34, "Lunch"

      expect { click_on "Submit" }
        .to change(CaseContact.active, :count).by(1)
        .and change(AdditionalExpense, :count).by(1)

      visit edit_case_contact_path(casa_case.reload.case_contacts.last)

      expect(page).to have_field(class: "expense-amount-input", with: "5.34")
      expect(page).to have_field(class: "expense-describe-input", with: "Lunch")
      expect(page).to have_button "Add Expense"
    end

    it "additional expenses for multiple entries" do
      subject

      click_on "Add Expense"
      fill_expense_fields 7.21, "Toll"

      click_on "Add Expense"

      expect(page).to have_field(class: "expense-describe-input", count: 2)
      expect(page).to have_field(class: "expense-amount-input", count: 2)

      fill_expense_fields 7.22, "Another Toll"

      expect {
        click_on "Submit"
      }.to change(CaseContact.active, :count).by(1).and change(AdditionalExpense, :count).by(2)

      case_contact = CaseContact.last
      visit edit_case_contact_path(case_contact)

      expect(page).to have_text "Edit"
      amount_fields = all(".expense-amount-input")
      describe_fields = all(".expense-describe-input")

      expect(amount_fields[0].value).to eq("7.21")
      expect(describe_fields[0].value).to eq("Toll")
      expect(amount_fields[1].value).to eq("7.22")
      expect(describe_fields[1].value).to eq("Another Toll")
      expect(page).to have_button "Add Expense"

      click_on "Add Expense"

      describe_fields[0].fill_in(with: "Breakfast")
      amount_fields[1].fill_in(with: "7.23")

      click_on "Add Expense"
      fill_expense_fields 8.23, "Yet another toll"

      expect {
        click_on "Submit"
      }.to change(CaseContact.active, :count).by(0).and change(AdditionalExpense, :count).by(1)

      visit edit_case_contact_path(case_contact)

      expect(page).to have_text("Edit")
      amount_fields = all(".expense-amount-input")
      describe_fields = all(".expense-describe-input")

      expect(amount_fields[2].value).to eq("8.23")
      expect(describe_fields[2].value).to eq("Yet another toll")
      expect(describe_fields[0].value).to eq("Breakfast")
      expect(amount_fields[1].value).to eq("7.23")

      expect(amount_fields.size).to eq(3)
      expect(describe_fields.size).to eq(3)

      click_on "Add Expense"
      expect(page).to have_selector(".expense-amount-input", count: 4)
      expect(page).to have_selector(".expense-describe-input", count: 4)
    end

    it "additional expenses for more than ten entries" do
      subject

      expect(page).to have_button "Add Expense"

      expect(page).to have_no_selector(".expense-amount-input")
      expect(page).to have_no_selector(".expense-describe-input")

      click_on "Add Expense"

      fill_expense_fields 0.11, "1 meal"

      11.times do |i|
        click_on "Add Expense"
        expect(page).to have_selector(".expense-amount-input", count: i + 2)
        expect(page).to have_selector(".expense-describe-input", count: i + 2)

        fill_expense_fields(i + 1.11, "#{i + 2} meal")
      end

      expect {
        click_on "Submit"
      }.to change(CaseContact.active, :count).by(1).and change(AdditionalExpense, :count).by(12)

      case_contact = CaseContact.last
      visit edit_case_contact_path(casa_case.reload.case_contacts.last)

      expect(page).to have_selector(".expense-amount-input", count: 12)
      expect(page).to have_selector(".expense-describe-input", count: 12)

      12.times do |i|
        expect(page).to have_field(class: "expense-amount-input", with: "#{i}.11")
        expect(page).to have_field(class: "expense-describe-input", with: "#{i + 1} meal")
      end

      expect(case_contact.additional_expenses.count).to eq(12)
      expect(page).to have_button "Add Expense"
    end

    it "additional expenses can be deleted" do
      subject

      click_on "Add Expense"
      fill_expense_fields(0.11, "1 meal")

      expect(page).to have_selector(".expense-amount-input", count: 1)

      click_on "Add Expense"

      expect(page).to have_selector(".expense-amount-input", count: 2)

      fill_expense_fields 1.11, "2 meal"

      expect {
        click_on "Submit"
      }.to change(CaseContact.active, :count).by(1).and change(AdditionalExpense, :count).by(2)

      visit edit_case_contact_path(casa_case.reload.case_contacts.last)
      expect(page).to have_selector(".expense-amount-input", count: 2)
      expect(page).to have_selector(".expense-describe-input", count: 2)

      all("button.remove-expense-button").last.click

      expect(page).to have_selector(".expense-amount-input", count: 1)
      expect(page).to have_selector(".expense-describe-input", count: 1)

      expect {
        click_on "Submit"
      }.to change(CaseContact.active, :count).by(0).and change(AdditionalExpense, :count).by(-1)
    end

    it "verifies that an additional expense without a description will cause an error" do
      subject

      click_on "Add Expense"
      fill_expense_fields 5.34, nil

      expect {
        click_on "Submit"
      }.to change(CaseContact.active, :count).by(0).and change(AdditionalExpense, :count).by(0)

      expect(page).to have_text("error")

      fill_expense_fields nil, "1 meal"

      expect { click_on "Submit" }
        .to change(CaseContact.active, :count).by(1)
        .and change(AdditionalExpense, :count).by(1)

      expect(page).not_to have_text("error")

      visit edit_case_contact_path(casa_case.reload.case_contacts.last)
      click_on "Add Expense"
      fill_expense_fields 7.45, nil

      expect { click_on "Submit" }
        .to change(CaseContact.active, :count).by(0)
        .and change(AdditionalExpense, :count).by(0)
      expect(page).to have_text("error")

      fill_expense_fields(nil, "2nd meal")

      expect { click_on "Submit" }
        .to change(CaseContact.active, :count).by(0)
        .and change(AdditionalExpense, :count).by(1)

      expect(page).not_to have_text("error")
    end

    it "can remove an expense" do
      subject
      fill_in_contact_details

      click_on "Add Expense"
      fill_expense_fields 1.50, "1st meal"
      click_on "Add Expense"
      fill_expense_fields 2.50, "2nd meal"
      click_on "Add Expense"
      fill_expense_fields 2.00, "3rd meal"

      page.all(".remove-expense-button")[1].click
      expect(page).to have_field(class: "expense-amount-input", count: 2)

      expect { click_on "Submit" }
        .to change(CaseContact.active, :count).by(1)
        .and change(AdditionalExpense, :count).by(2)

      case_contact = CaseContact.active.last
      expect(case_contact.additional_expenses.map(&:other_expense_amount)).to match_array([1.50, 2.00])
      expect(case_contact.additional_expenses.map(&:other_expenses_describe)).to match_array(["1st meal", "3rd meal"])
    end
  end
end

require "rails_helper"
require "action_view"

RSpec.describe "additional_expenses", type: :system do
  let(:organization) { build(:casa_org, additional_expenses_enabled: true) }
  let(:volunteer) { create(:volunteer, casa_org: organization) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }

  before do
    allow(Flipper).to receive(:enabled?).with(:show_additional_expenses).and_return(true)
    create(:case_assignment, casa_case: casa_case, volunteer: volunteer)
  end

  it "can be set per organization", js: true do
    other_organization = build(:casa_org)
    other_volunteer = create(:volunteer, casa_org: other_organization)
    other_casa_case = create(:casa_case, casa_org: other_organization)
    create(:case_assignment, casa_case: other_casa_case, volunteer: other_volunteer)

    sign_in volunteer
    visit casa_case_path(casa_case.id)
    click_on "New Case Contact"

    complete_details_page(case_numbers: [], contact_types: [], contact_made: true, medium: "Video", occurred_on: "04/04/2020", hours: 1, minutes: 45)
    complete_notes_page

    expect(page).to have_text("Other Expenses")

    sign_in other_volunteer
    visit casa_case_path(other_casa_case.id)
    click_on "New Case Contact"

    complete_details_page(case_numbers: [], contact_types: [], contact_made: true, medium: "Video", occurred_on: "04/04/2020", hours: 1, minutes: 45)
    complete_notes_page

    expect(page).not_to have_text("Other Expenses")
  end

  context "when setting additional expenses" do
    let(:contact_type_group) { build(:contact_type_group, casa_org: organization) }

    before do
      create(:contact_type)
      create(:contact_type, name: "School", contact_type_group: contact_type_group)
    end

    it "additional expenses fields appearance", js: true do
      sign_in volunteer

      visit casa_case_path(casa_case.id)

      click_on "New Case Contact"

      complete_details_page(case_numbers: [], contact_types: [], contact_made: true, medium: "Video", occurred_on: "04/04/2020", hours: 1, minutes: 45)
      complete_notes_page

      expect(page).to have_text("Add Another Expense")

      expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expense_amount")
      expect(page).to have_no_field("case_contact_additional_expenses_attributes_1_other_expense_amount")
      find_by_id("case_contact_additional_expenses_attributes_0_other_expense_amount").fill_in(with: "5.34")
      find_by_id("case_contact_additional_expenses_attributes_0_other_expenses_describe").fill_in(with: "Lunch")

      expect {
        click_on "Submit"
      }.to change(CaseContact.where(status: "active"), :count).by(1).and change(AdditionalExpense, :count).by(1)

      visit edit_case_contact_path(casa_case.reload.case_contacts.last)
      complete_details_page(contact_made: true)
      complete_notes_page

      expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expense_amount", with: "5.34")
      expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expenses_describe", with: "Lunch")

      expect(page).to have_text("Add Another Expense")
    end

    it "additional expenses for multiple entries", js: true do
      sign_in volunteer

      visit casa_case_path(casa_case.id)

      click_on "New Case Contact"

      complete_details_page(case_numbers: [], contact_types: [], contact_made: true, medium: "Video", occurred_on: "04/04/2020", hours: 1, minutes: 45)
      complete_notes_page

      expect(page).to have_text("Add Another Expense")

      expect(page).to have_selector("input[name*='[additional_expenses_attributes]'][name$='[other_expense_amount]']", count: 1)
      expect(page).to have_selector("input[name*='[additional_expenses_attributes]'][name$='[other_expenses_describe]']", count: 1)

      all("input[name*='[additional_expenses_attributes]'][name$='[other_expense_amount]']").first.fill_in(with: "7.21")
      all("input[name*='[additional_expenses_attributes]'][name$='[other_expenses_describe]']").first.fill_in(with: "Toll")

      find_by_id("add-another-expense").click

      expect(page).to have_selector("input[name*='[additional_expenses_attributes]'][name$='[other_expense_amount]']", count: 2)
      expect(page).to have_selector("input[name*='[additional_expenses_attributes]'][name$='[other_expenses_describe]']", count: 2)

      all("input[name*='[additional_expenses_attributes]'][name$='[other_expense_amount]']").last.fill_in(with: "7.22")
      all("input[name*='[additional_expenses_attributes]'][name$='[other_expenses_describe]']").last.fill_in(with: "Another Toll")

      expect(page).to have_text("Add Another Expense")
      expect {
        click_on "Submit"
      }.to change(CaseContact.where(status: "active"), :count).by(1).and change(AdditionalExpense, :count).by(2)

      visit edit_case_contact_path(casa_case.reload.case_contacts.last)
      complete_details_page(contact_made: true)
      complete_notes_page

      amount_fields = all("input[name*='[additional_expenses_attributes]'][name$='[other_expense_amount]']")
      describe_fields = all("input[name*='[additional_expenses_attributes]'][name$='[other_expenses_describe]']")

      expect(amount_fields[0].value).to eq("7.21")
      expect(describe_fields[0].value).to eq("Toll")
      expect(amount_fields[1].value).to eq("7.22")
      expect(describe_fields[1].value).to eq("Another Toll")
      expect(page).to have_text("Add Another Expense")

      find_by_id("add-another-expense").click

      describe_fields[0].fill_in(with: "Breakfast")
      amount_fields[1].fill_in(with: "7.23")
      all("input[name*='[additional_expenses_attributes]'][name$='[other_expense_amount]']").last.fill_in(with: "8.23")
      all("input[name*='[additional_expenses_attributes]'][name$='[other_expenses_describe]']").last.fill_in(with: "Yet another toll")

      expect {
        click_on "Submit"
      }.to change(CaseContact.where(status: "active"), :count).by(0).and change(AdditionalExpense, :count).by(1)

      visit edit_case_contact_path(casa_case.reload.case_contacts.last)
      complete_details_page(contact_made: true)
      complete_notes_page

      amount_fields = all("input[name*='[additional_expenses_attributes]'][name$='[other_expense_amount]']")
      describe_fields = all("input[name*='[additional_expenses_attributes]'][name$='[other_expenses_describe]']")

      expect(amount_fields[2].value).to eq("8.23")
      expect(describe_fields[2].value).to eq("Yet another toll")
      expect(describe_fields[0].value).to eq("Breakfast")
      expect(amount_fields[1].value).to eq("7.23")

      expect(page).to have_selector("input[name*='[additional_expenses_attributes]'][name$='[other_expense_amount]']", count: 3)

      find_by_id("add-another-expense").click
      expect(page).to have_selector("input[name*='[additional_expenses_attributes]'][name$='[other_expense_amount]']", count: 4)
    end

    it "additional expenses for more than ten entries", js: true do
      sign_in volunteer

      visit casa_case_path(casa_case.id)

      click_on "New Case Contact"

      complete_details_page(case_numbers: [], contact_types: [], contact_made: true, medium: "Video", occurred_on: "04/04/2020", hours: 1, minutes: 45)
      complete_notes_page

      expect(page).to have_text("Add Another Expense")

      expect(page).to have_selector("input[name*='[additional_expenses_attributes]'][name$='[other_expense_amount]']", count: 1)
      expect(page).to have_selector("input[name*='[additional_expenses_attributes]'][name$='[other_expenses_describe]']", count: 1)

      all("input[name*='[additional_expenses_attributes]'][name$='[other_expense_amount]']").first.fill_in(with: "0.11")
      all("input[name*='[additional_expenses_attributes]'][name$='[other_expenses_describe]']").first.fill_in(with: "1 meal")

      11.times do |i|
        find_by_id("add-another-expense").click
        expect(page).to have_selector("input[name*='[additional_expenses_attributes]'][name$='[other_expense_amount]']", count: i + 2)
        expect(page).to have_selector("input[name*='[additional_expenses_attributes]'][name$='[other_expenses_describe]']", count: i + 2)

        all("input[name*='[additional_expenses_attributes]'][name$='[other_expense_amount]']").last.fill_in(with: "#{i + 1}.11")
        all("input[name*='[additional_expenses_attributes]'][name$='[other_expenses_describe]']").last.fill_in(with: "#{i + 2} meal")
      end

      expect {
        click_on "Submit"
      }.to change(CaseContact.where(status: "active"), :count).by(1).and change(AdditionalExpense, :count).by(12)

      visit edit_case_contact_path(casa_case.reload.case_contacts.last)
      complete_details_page(contact_made: true)
      complete_notes_page

      expect(page).to have_selector("input[name*='[additional_expenses_attributes]'][name$='[other_expense_amount]']", count: 12)
      expect(page).to have_selector("input[name*='[additional_expenses_attributes]'][name$='[other_expenses_describe]']", count: 12)

      amount_fields = all("input[name*='[additional_expenses_attributes]'][name$='[other_expense_amount]']")
      describe_fields = all("input[name*='[additional_expenses_attributes]'][name$='[other_expenses_describe]']")

      12.times do |i|
        expect(amount_fields[i].value).to eq("#{i}.11")
        expect(describe_fields[i].value).to eq("#{i + 1} meal")
      end

      expect(page).to have_no_selector("input[name*='[additional_expenses_attributes]'][name$='[other_expense_amount]']", count: 13)
      expect(page).to have_no_selector("input[name*='[additional_expenses_attributes]'][name$='[other_expenses_describe]']", count: 13)

      expect(casa_case.case_contacts.last.additional_expenses.count).to eq(12)
      expect(page).to have_text("Add Another Expense")
    end

    it "additional expenses can be deleted", js: true do
      sign_in volunteer
      visit casa_case_path(casa_case.id)
      click_on "New Case Contact"

      complete_details_page(case_numbers: [], contact_types: [], contact_made: true, medium: "Video", occurred_on: "04/04/2020", hours: 1, minutes: 45)
      complete_notes_page

      find_by_id("case_contact_additional_expenses_attributes_0_other_expense_amount").fill_in(with: "0.11")
      find_by_id("case_contact_additional_expenses_attributes_0_other_expenses_describe").fill_in(with: "1 meal")

      expect(page).to have_selector("input[name*='case_contact[additional_expenses_attributes]'][name$='[other_expense_amount]']", count: 1)

      find_by_id("add-another-expense").click

      expect(page).to have_selector("input[name*='case_contact[additional_expenses_attributes]'][name$='[other_expense_amount]']", count: 2)

      all("input[name*='case_contact[additional_expenses_attributes]'][name$='[other_expense_amount]']").last.fill_in(with: "1.11")
      all("input[name*='case_contact[additional_expenses_attributes]'][name$='[other_expenses_describe]']").last.fill_in(with: "2 meal")

      expect {
        click_on "Submit"
      }.to change(CaseContact.where(status: "active"), :count).by(1).and change(AdditionalExpense, :count).by(2)

      visit edit_case_contact_path(casa_case.reload.case_contacts.last)
      complete_details_page(contact_made: true)
      complete_notes_page

      all("button.remove-expense-button").last.click

      expect(page).to have_selector("input[name*='case_contact[additional_expenses_attributes]'][name$='[other_expense_amount]']", count: 1)
      expect(page).to have_selector("input[name*='case_contact[additional_expenses_attributes]'][name$='[other_expenses_describe]']", count: 1)

      expect {
        click_on "Submit"
      }.to change(CaseContact.where(status: "active"), :count).by(0).and change(AdditionalExpense, :count).by(-1)
    end

    it "verifies that an additional expense without a description will cause an error", js: true do
      sign_in volunteer

      visit casa_case_path(casa_case.id)

      click_on "New Case Contact"

      complete_details_page(case_numbers: [], contact_types: [], contact_made: true, medium: "Video", occurred_on: "04/04/2020", hours: 1, minutes: 45)
      complete_notes_page
      expect(page).to have_text("Add Another Expense")
      expect(page).to have_selector("input[name*='[additional_expenses_attributes]'][name$='[other_expense_amount]']", count: 1)
      expect(page).to have_selector("input[name*='[additional_expenses_attributes]'][name$='[other_expenses_describe]']", count: 1)

      all("input[name*='[additional_expenses_attributes]'][name$='[other_expense_amount]']").first.fill_in(with: "5.34")

      expect {
        click_on "Submit"
      }.to change(CaseContact.where(status: "active"), :count).by(0).and change(AdditionalExpense, :count).by(0)

      expect(page).to have_text("error")

      all("input[name*='[additional_expenses_attributes]'][name$='[other_expenses_describe]']").first.fill_in(with: "1 meal")

      expect {
        click_on "Submit"
      }.to change(CaseContact.where(status: "active"), :count).by(1).and change(AdditionalExpense, :count).by(1)
      expect(page).not_to have_text("error")

      visit edit_case_contact_path(casa_case.reload.case_contacts.last)
      complete_details_page(contact_made: true)
      complete_notes_page

      find_by_id("add-another-expense").click

      all("input[name*='[additional_expenses_attributes]'][name$='[other_expense_amount]']").last.fill_in(with: "7.45")

      expect {
        click_on "Submit"
      }.to change(CaseContact.where(status: "active"), :count).by(0).and change(AdditionalExpense, :count).by(0)
      expect(page).to have_text("error")

      all("input[name*='[additional_expenses_attributes]'][name$='[other_expenses_describe]']").last.fill_in(with: "2nd meal")

      expect {
        click_on "Submit"
      }.to change(CaseContact.where(status: "active"), :count).by(0).and change(AdditionalExpense, :count).by(1)
      expect(page).not_to have_text("error")
    end
  end
end

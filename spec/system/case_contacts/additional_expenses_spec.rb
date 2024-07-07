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
      expect(page).to have_field("case_contact_additional_expenses_attributes_1_other_expense_amount")
      expect(page).to have_no_field("case_contact_additional_expenses_attributes_2_other_expense_amount")
      expect(page).to have_text("Add Another Expense")
    end

    it "additional expenses for multiple entries", js: true do
      sign_in volunteer

      visit casa_case_path(casa_case.id)

      click_on "New Case Contact"

      complete_details_page(case_numbers: [], contact_types: [], contact_made: true, medium: "Video", occurred_on: "04/04/2020", hours: 1, minutes: 45)
      complete_notes_page

      expect(page).to have_text("Add Another Expense")
      expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expense_amount")
      expect(page).to have_no_field("case_contact_additional_expenses_attributes_1_other_expense_amount")
      find_by_id("case_contact_additional_expenses_attributes_0_other_expense_amount").fill_in(with: "7.21")
      find_by_id("case_contact_additional_expenses_attributes_0_other_expenses_describe").fill_in(with: "Toll")

      find_by_id("add-another-expense").click
      expect(page).to have_field("case_contact_additional_expenses_attributes_1_other_expense_amount")
      expect(page).to have_no_field("case_contact_additional_expenses_attributes_2_other_expense_amount")

      find_by_id("case_contact_additional_expenses_attributes_1_other_expense_amount").fill_in(with: "7.22")
      find_by_id("case_contact_additional_expenses_attributes_1_other_expenses_describe").fill_in(with: "Another Toll")
      expect(page).to have_text("Add Another Expense")

      expect {
        click_on "Submit"
      }.to change(CaseContact.where(status: "active"), :count).by(1).and change(AdditionalExpense, :count).by(2)

      visit edit_case_contact_path(casa_case.reload.case_contacts.last)
      complete_details_page(contact_made: true)
      complete_notes_page

      expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expense_amount", with: "7.21")
      expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expenses_describe", with: "Toll")
      expect(page).to have_field("case_contact_additional_expenses_attributes_1_other_expense_amount", with: "7.22")
      expect(page).to have_field("case_contact_additional_expenses_attributes_1_other_expenses_describe", with: "Another Toll")
      expect(page).to have_field("case_contact_additional_expenses_attributes_2_other_expense_amount")
      expect(page).to have_text("Add Another Expense")

      find_by_id("case_contact_additional_expenses_attributes_0_other_expenses_describe").fill_in(with: "Breakfast")
      find_by_id("case_contact_additional_expenses_attributes_1_other_expense_amount").fill_in(with: "7.23")
      find_by_id("case_contact_additional_expenses_attributes_2_other_expense_amount").fill_in(with: "8.23")
      find_by_id("case_contact_additional_expenses_attributes_2_other_expenses_describe").fill_in(with: "Yet another toll")

      expect {
        click_on "Submit"
      }.to change(CaseContact.where(status: "active"), :count).by(0).and change(AdditionalExpense, :count).by(1)

      visit edit_case_contact_path(casa_case.reload.case_contacts.last)
      complete_details_page(contact_made: true)
      complete_notes_page

      expect(page).to have_field("case_contact_additional_expenses_attributes_2_other_expense_amount", with: "8.23")
      expect(page).to have_field("case_contact_additional_expenses_attributes_2_other_expenses_describe", with: "Yet another toll")
      expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expenses_describe", with: "Breakfast")
      expect(page).to have_field("case_contact_additional_expenses_attributes_1_other_expense_amount", with: "7.23")
      expect(page).to have_field("case_contact_additional_expenses_attributes_3_other_expense_amount")
      expect(page).to have_no_field("case_contact_additional_expenses_attributes_4_other_expense_amount")
      find_by_id("add-another-expense").click
      expect(page).to have_field("case_contact_additional_expenses_attributes_4_other_expense_amount")
    end

    it "additional expenses for maximum entries", js: true do
      sign_in volunteer

      visit casa_case_path(casa_case.id)

      click_on "New Case Contact"

      complete_details_page(case_numbers: [], contact_types: [], contact_made: true, medium: "Video", occurred_on: "04/04/2020", hours: 1, minutes: 45)
      complete_notes_page

      expect(page).to have_text("Add Another Expense")

      expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expense_amount")
      expect(page).to have_no_field("case_contact_additional_expenses_attributes_1_other_expense_amount")
      expect(page).to have_no_field("case_contact_additional_expenses_attributes_1_other_expenses_describe")
      find_by_id("case_contact_additional_expenses_attributes_0_other_expense_amount").fill_in(with: "0.11")
      find_by_id("case_contact_additional_expenses_attributes_0_other_expenses_describe").fill_in(with: "1 meal")
      expect(page).to have_text("Add Another Expense")

      (1..9).each { |i|
        find_by_id("add-another-expense").click
        expect(page).to have_field("case_contact_additional_expenses_attributes_#{i}_other_expense_amount")
        expect(page).to have_field("case_contact_additional_expenses_attributes_#{i}_other_expenses_describe")
        expect(page).to have_no_field("case_contact_additional_expenses_attributes_#{i + 1}_other_expense_amount")
        expect(page).to have_no_field("case_contact_additional_expenses_attributes_#{i + 1}_other_expenses_describe")
        find_by_id("case_contact_additional_expenses_attributes_#{i}_other_expense_amount").fill_in(with: "#{i}.11")
        find_by_id("case_contact_additional_expenses_attributes_#{i}_other_expenses_describe").fill_in(with: "#{i + 1} meal")
      }

      expect {
        click_on "Submit"
      }.to change(CaseContact.where(status: "active"), :count).by(1).and change(AdditionalExpense, :count).by(10)

      visit edit_case_contact_path(casa_case.reload.case_contacts.last)
      complete_details_page(contact_made: true)
      complete_notes_page

      expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expense_amount", with: "0.11")
      expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expenses_describe", with: "1 meal")
      expect(page).to have_field("case_contact_additional_expenses_attributes_1_other_expense_amount", with: "1.11")
      expect(page).to have_field("case_contact_additional_expenses_attributes_1_other_expenses_describe", with: "2 meal")
      expect(page).to have_field("case_contact_additional_expenses_attributes_2_other_expense_amount", with: "2.11")
      expect(page).to have_field("case_contact_additional_expenses_attributes_2_other_expenses_describe", with: "3 meal")
      expect(page).to have_field("case_contact_additional_expenses_attributes_3_other_expense_amount", with: "3.11")
      expect(page).to have_field("case_contact_additional_expenses_attributes_3_other_expenses_describe", with: "4 meal")
      expect(page).to have_field("case_contact_additional_expenses_attributes_4_other_expense_amount", with: "4.11")
      expect(page).to have_field("case_contact_additional_expenses_attributes_4_other_expenses_describe", with: "5 meal")
      expect(page).to have_field("case_contact_additional_expenses_attributes_5_other_expense_amount", with: "5.11")
      expect(page).to have_field("case_contact_additional_expenses_attributes_5_other_expenses_describe", with: "6 meal")
      expect(page).to have_field("case_contact_additional_expenses_attributes_6_other_expense_amount", with: "6.11")
      expect(page).to have_field("case_contact_additional_expenses_attributes_6_other_expenses_describe", with: "7 meal")
      expect(page).to have_field("case_contact_additional_expenses_attributes_7_other_expense_amount", with: "7.11")
      expect(page).to have_field("case_contact_additional_expenses_attributes_7_other_expenses_describe", with: "8 meal")
      expect(page).to have_field("case_contact_additional_expenses_attributes_8_other_expense_amount", with: "8.11")
      expect(page).to have_field("case_contact_additional_expenses_attributes_8_other_expenses_describe", with: "9 meal")
      expect(page).to have_field("case_contact_additional_expenses_attributes_9_other_expense_amount", with: "9.11")
      expect(page).to have_field("case_contact_additional_expenses_attributes_9_other_expenses_describe", with: "10 meal")

      expect(page).to have_no_field("case_contact_additional_expenses_attributes_10_other_expense_amount")
      expect(page).to have_no_field("case_contact_additional_expenses_attributes_10_other_expenses_describe")
      expect(casa_case.case_contacts.last.additional_expenses.count).to eq(10)
      expect(page).to have_no_text("Add Another Expense")
    end

    it "verifies that an additional expense without a description will cause an error", js: true do
      sign_in volunteer

      visit casa_case_path(casa_case.id)

      click_on "New Case Contact"

      complete_details_page(case_numbers: [], contact_types: [], contact_made: true, medium: "Video", occurred_on: "04/04/2020", hours: 1, minutes: 45)
      complete_notes_page

      expect(page).to have_text("Add Another Expense")
      expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expense_amount")
      expect(page).to have_no_field("case_contact_additional_expenses_attributes_1_other_expense_amount")
      find_by_id("case_contact_additional_expenses_attributes_0_other_expense_amount").fill_in(with: "5.34")

      expect {
        click_on "Submit"
      }.to change(CaseContact.where(status: "active"), :count).by(0).and change(AdditionalExpense, :count).by(0)

      expect(page).to have_text("error")

      find_by_id("case_contact_additional_expenses_attributes_0_other_expenses_describe").fill_in(with: "1 meal")

      expect {
        click_on "Submit"
      }.to change(CaseContact.where(status: "active"), :count).by(1).and change(AdditionalExpense, :count).by(1)
      expect(page).not_to have_text("error")

      visit edit_case_contact_path(casa_case.reload.case_contacts.last)
      complete_details_page(contact_made: true)
      complete_notes_page

      # Confirming validation and correct errors to user for update method
      find_by_id("case_contact_additional_expenses_attributes_1_other_expense_amount").fill_in(with: "7.45")

      expect {
        click_on "Submit"
      }.to change(CaseContact.where(status: "active"), :count).by(0).and change(AdditionalExpense, :count).by(0)
      expect(page).to have_text("error")

      find_by_id("case_contact_additional_expenses_attributes_1_other_expenses_describe").fill_in(with: "2nd meal")

      expect {
        click_on "Submit"
      }.to change(CaseContact.where(status: "active"), :count).by(0).and change(AdditionalExpense, :count).by(1)
      expect(page).not_to have_text("error")
    end
  end
end

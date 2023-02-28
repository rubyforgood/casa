require "rails_helper"
require "action_view"

RSpec.describe "addtional_expenses", type: :system do
  it "additional expenses fields appearance", js: true do
    FeatureFlagService.enable!("show_additional_expenses")
    organization = build(:casa_org)
    volunteer = create(:volunteer, casa_org: organization)
    casa_case = create(:casa_case, casa_org: organization)
    create(:case_assignment, casa_case: casa_case, volunteer: volunteer)
    contact_type_group = build(:contact_type_group, casa_org: organization)
    create(:contact_type)
    create(:contact_type, name: "School", contact_type_group: contact_type_group)

    sign_in volunteer

    visit casa_case_path(casa_case.id)

    click_on "New Case Contact"

    fill_out_minimum_required_fields_for_case_contact_form

    expect(page).to have_text("Add Another Expense")
    expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expense_amount")
    expect(page).to have_no_field("case_contact_additional_expenses_attributes_1_other_expense_amount")
    find_by_id("case_contact_additional_expenses_attributes_0_other_expense_amount").fill_in(with: "5.34")
    find_by_id("case_contact_additional_expenses_attributes_0_other_expenses_describe").fill_in(with: "Lunch")

    expect {
      click_on "Submit"
    }.to change(CaseContact, :count).by(1).and change(AdditionalExpense, :count).by(1)

    visit edit_case_contact_path(casa_case.reload.case_contacts.last)
    expect(page).to have_text("Editing Case Contact")
    expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expense_amount", with: "5.34")
    expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expenses_describe", with: "Lunch")
    expect(page).to have_field("case_contact_additional_expenses_attributes_1_other_expense_amount")
    expect(page).to have_no_field("case_contact_additional_expenses_attributes_2_other_expense_amount")
    expect(page).to have_text("Add Another Expense")
  end
  it "additional expenses for multiple entries", js: true do
    FeatureFlagService.enable!("show_additional_expenses")
    organization = build(:casa_org)
    volunteer = create(:volunteer, casa_org: organization)
    casa_case = create(:casa_case, casa_org: organization)
    create(:case_assignment, casa_case: casa_case, volunteer: volunteer)
    contact_type_group = build(:contact_type_group, casa_org: organization)
    create(:contact_type)
    create(:contact_type, name: "School", contact_type_group: contact_type_group)

    sign_in volunteer

    visit casa_case_path(casa_case.id)

    click_on "New Case Contact"

    fill_out_minimum_required_fields_for_case_contact_form

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
    }.to change(CaseContact, :count).by(1).and change(AdditionalExpense, :count).by(2)

    visit edit_case_contact_path(casa_case.reload.case_contacts.last)
    expect(page).to have_text("Editing Case Contact")
    expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expense_amount", with: "7.21")
    expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expenses_describe", with: "Toll")
    expect(page).to have_field("case_contact_additional_expenses_attributes_1_other_expense_amount", with: "7.22")
    expect(page).to have_field("case_contact_additional_expenses_attributes_1_other_expenses_describe", with: "Another Toll")
    expect(page).to have_field("case_contact_additional_expenses_attributes_2_other_expense_amount")
    expect(page).to have_text("Add Another Expense")

    find_by_id("case_contact_additional_expenses_attributes_0_other_expenses_describe").fill_in(with: "") # This is a hack to fix a bug involving capybara and headless chrome
    # More about the bug here: https://github.com/redux-form/redux-form/issues/686#issuecomment-326673386
    find_by_id("case_contact_additional_expenses_attributes_0_other_expenses_describe").fill_in(with: "Breakfast")
    find_by_id("case_contact_additional_expenses_attributes_1_other_expense_amount").fill_in(with: "7.23")
    find_by_id("case_contact_additional_expenses_attributes_2_other_expense_amount").fill_in(with: "8.23")
    find_by_id("case_contact_additional_expenses_attributes_2_other_expenses_describe").fill_in(with: "Yet another toll")

    expect {
      click_on "Submit"
    }.to change(CaseContact, :count).by(0).and change(AdditionalExpense, :count).by(1)

    visit edit_case_contact_path(casa_case.reload.case_contacts.last)

    expect(page).to have_text("Editing Case Contact")
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
    FeatureFlagService.enable!("show_additional_expenses")
    organization = build(:casa_org)
    volunteer = create(:volunteer, casa_org: organization)
    casa_case = create(:casa_case, casa_org: organization)
    create(:case_assignment, casa_case: casa_case, volunteer: volunteer)
    contact_type_group = build(:contact_type_group, casa_org: organization)
    create(:contact_type)
    create(:contact_type, name: "School", contact_type_group: contact_type_group)

    sign_in volunteer

    visit casa_case_path(casa_case.id)

    click_on "New Case Contact"

    fill_out_minimum_required_fields_for_case_contact_form

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
    }.to change(CaseContact, :count).by(1).and change(AdditionalExpense, :count).by(10)

    visit edit_case_contact_path(casa_case.reload.case_contacts.last)
    expect(page).to have_text("Editing Case Contact")
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
    expect(page).to have_no_text("Add Another Expense")
  end

  it "verifies that an additional expense without a description will cause an error", js: true do
    FeatureFlagService.enable!("show_additional_expenses")
    organization = build(:casa_org)
    volunteer = create(:volunteer, casa_org: organization)
    casa_case = create(:casa_case, casa_org: organization)
    create(:case_assignment, casa_case: casa_case, volunteer: volunteer)
    contact_type_group = build(:contact_type_group, casa_org: organization)
    create(:contact_type)
    create(:contact_type, name: "School", contact_type_group: contact_type_group)

    sign_in volunteer

    visit casa_case_path(casa_case.id)

    click_on "New Case Contact"

    fill_out_minimum_required_fields_for_case_contact_form

    expect(page).to have_text("Add Another Expense")
    expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expense_amount")
    expect(page).to have_no_field("case_contact_additional_expenses_attributes_1_other_expense_amount")
    find_by_id("case_contact_additional_expenses_attributes_0_other_expense_amount").fill_in(with: "5.34")

    expect {
      click_on "Submit"
    }.to change(CaseContact, :count).by(0).and change(AdditionalExpense, :count).by(0)

    expect(page).to have_text("error")

    find_by_id("case_contact_additional_expenses_attributes_0_other_expenses_describe").fill_in(with: "1 meal")

    expect {
      click_on "Submit"
    }.to change(CaseContact, :count).by(1).and change(AdditionalExpense, :count).by(1)
    expect(page).not_to have_text("error")

    visit edit_case_contact_path(casa_case.reload.case_contacts.last)
    # Confirming validation and correct errors to user for update method

    find_by_id("case_contact_additional_expenses_attributes_1_other_expense_amount").fill_in(with: "7.45")

    expect {
      click_on "Submit"
    }.to change(CaseContact, :count).by(0).and change(AdditionalExpense, :count).by(0)
    expect(page).to have_text("error")

    find_by_id("case_contact_additional_expenses_attributes_1_other_expenses_describe").fill_in(with: "2nd meal")

    expect {
      click_on "Submit"
    }.to change(CaseContact, :count).by(0).and change(AdditionalExpense, :count).by(1)
    expect(page).not_to have_text("error")
  end
end

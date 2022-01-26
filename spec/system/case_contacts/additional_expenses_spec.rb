require "rails_helper"
require "action_view"

RSpec.describe "addtional_expenses", type: :system do
  it "additional expenses", js: true do
    FeatureFlagService.enable!("show_additional_expenses")
    organization = build(:casa_org)
    volunteer = create(:volunteer, casa_org: organization)
    casa_case = create(:casa_case, casa_org: organization)
    create(:case_assignment, casa_case: casa_case, volunteer: volunteer)
    contact_type_group = build(:contact_type_group, casa_org: organization)
    contact_type = create(:contact_type)
    school = create(:contact_type, name: "School", contact_type_group: contact_type_group)

    sign_in volunteer

    visit casa_case_path(casa_case.id)

    click_on "New Case Contact"

    check "School"
    choose "Yes"
    select "Video", from: "case_contact[medium_type]"
    fill_in "case_contact_occurred_at", with: "04/04/2020"

    fill_in "case-contact-duration-hours", with: "1"
    fill_in "case-contact-duration-minutes", with: "45"
    fill_in "case_contact_miles_driven", with: "0"

    # PUT BACK LATER
    # expect(page).to have_text("Add another expense")

    # behavior should be, one default appearing field and clicking Add another expense adds a new field

    expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expense_amount")
    # THIS IS NEXT
    # expect(page).to have_no_field("case_contact_additional_expenses_attributes_1_other_expense_amount")

    # click_on "Add another expense"

    # Next test that "case_contact_additional_expenses_attributes_1_other_expense_amount" has appeared, but not "case_contact_additional_expenses_attributes_2_other_expense_amount"

    find_by_id("case_contact_additional_expenses_attributes_0_other_expense_amount").fill_in(with: "7.21")
    find_by_id("case_contact_additional_expenses_attributes_0_other_expenses_describe").fill_in(with: "Toll")

    find_by_id("case_contact_additional_expenses_attributes_1_other_expense_amount").fill_in(with: "7.22")
    find_by_id("case_contact_additional_expenses_attributes_1_other_expenses_describe").fill_in(with: "Another Toll")

    expect {
      click_on "Submit"
    }.to change(CaseContact, :count).by(1).and change(AdditionalExpense, :count).by(2)

    visit edit_case_contact_path(casa_case.reload.case_contacts.last)
    expect(page).to have_text("Editing Case Contact")
    expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expense_amount", with: "7.21")
    expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expenses_describe", with: "Toll")
    expect(page).to have_field("case_contact_additional_expenses_attributes_1_other_expense_amount", with: "7.22")
    expect(page).to have_field("case_contact_additional_expenses_attributes_1_other_expenses_describe", with: "Another Toll")

    # To test update adding a new set of additional expenses as well as modifying existing ones

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
  end
end

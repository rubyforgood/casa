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
    # should not be needed anymore
    fill_in "case_contact_miles_driven", with: "0"

    click_on "Add another expense"
    expect(page).to have_text("Add another expense")
    click_on "Add another expense"
    page.all("input.other-expense-amount").last.fill_in(with: "7.21")
    page.all("input.other-expenses-describe").last.fill_in(with: "Another Toll")

    expect {
      click_on "Submit"
    }.to change(CaseContact, :count).by(1).and change(AdditionalExpense, :count).by(1)

    # visit edit_case_contact_path(casa_case.reload.case_contacts.last)
    # expect(page).to have_text("Editing Case Contact")
    # visit "#case_contact_notes"
    # expect(page).to have_text("7.21")
    # expect(page).to have_text("Another Toll")

  end
end

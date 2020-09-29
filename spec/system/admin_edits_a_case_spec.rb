require "rails_helper"

RSpec.describe "admin edits case", type: :system do
  # Add back when Travis CI correctly handles large screen size
  xit "clicks back button after editing case" do
    volunteer = create(:volunteer)
    casa_case = create(:casa_case, casa_org: volunteer.casa_org)
    create(:case_assignment, volunteer: volunteer, casa_case: casa_case)

    admin = create(:casa_admin, casa_org: volunteer.casa_org)

    sign_in admin

    visit edit_casa_case_path(casa_case)

    check "Transition aged youth"
    check "Court report submitted"
    click_on "Update CASA Case"

    has_checked_field? :transition_aged_youth
    has_checked_field? :court_report_submitted

    click_on "Back"

    expect(page).to have_text("Volunteer")
    expect(page).to have_text("Case")
    expect(page).to have_text("Supervisor")
  end
end

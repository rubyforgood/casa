require "rails_helper"

RSpec.describe "admin edits case", type: :system do
  it "clicks back button after editing case" do
    
    volunteer = create(:volunteer)
    casa_case = create(:casa_case, casa_org: volunteer.casa_org)
    case_assignment = create(:case_assignment, volunteer: volunteer, casa_case: casa_case)

    admin = create(:casa_admin, casa_org: volunteer.casa_org)
    
    sign_in admin
    
    visit edit_casa_case_path(casa_case)

    check "Transition aged youth"
    click_on "Submit"
    
    has_checked_field? :transition_aged_youth

    click_on "Back"

    expect(page).to have_text("Volunteer")
    expect(page).to have_text("Case")
    expect(page).to have_text("Supervisor")
  end
end
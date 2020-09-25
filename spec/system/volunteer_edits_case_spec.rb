require "rails_helper"

RSpec.describe "volunteer edits case", type: :system do
  it "clicks back button after editing case" do
    volunteer = create(:volunteer)
    casa_case = create(:casa_case, casa_org: volunteer.casa_org)
    create(:case_assignment, volunteer: volunteer, casa_case: casa_case)

    sign_in volunteer
    visit edit_casa_case_path(casa_case)
    check "Transition aged youth"
    click_on "Submit"

    has_checked_field? :transition_aged_youth

    click_on "Back"

    expect(page).to have_text("My Case")
  end
end

require "rails_helper"

RSpec.feature "admin adds a new case", type: :feature do
  scenario "is successful" do
    admin = create(:user, :casa_admin)
    case_number = "12345"
    sign_in admin
    login_as admin
    visit root_path
    expect(page).to have_selector(".case-list")

    click_on "New Case"
    fill_in 'Case number', with: case_number


    expect(find_field('Case number').value).to eq case_number
    check "Teen program eligible"
    has_checked_field? "Teen program eligible"


    click_on "Create CASA case"
    expect(page.body).to have_content(case_number)
  end
end

require "rails_helper"

RSpec.describe "admin adds a new case", type: :system do
  it "is successful", js: false do
    admin = create(:casa_admin)
    case_number = "12345"
    sign_in admin
    visit root_path
    expect(page).to have_selector(".case-list")

    click_on "New Case"
    fill_in "Case number", with: case_number

    expect(find_field("Case number").value).to eq case_number
    check "Transition aged youth"
    has_checked_field? "Transition aged youth"

    click_on "Create CASA Case"
    expect(page.body).to have_content(case_number)
  end
end

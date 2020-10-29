require "rails_helper"

RSpec.describe "When an admin creates a new admin", type: :system do
  before do
    admin = create(:casa_admin)
    sign_in admin
    visit casa_admins_path
    click_on("New Admin")
  end

  it "they navigate to the new admin page" do
    expect(page).to have_content("Create New Casa Admin")
  end

  it "creates when providing a valid email" do
    fill_in "Email", with: "casa_admin1@example.com"
    fill_in "Display Name", with: "Derrick Dev"
    click_button("Submit")

    expect(page).to have_content "New Admin created."
  end

  it "fails when providing an invalid email" do
    fill_in "Email", with: "casa_admin1@"
    fill_in "Display Name", with: "Derrick Dev"
    click_button("Submit")

    expect(page).to have_content "Email is invalid"
  end
end

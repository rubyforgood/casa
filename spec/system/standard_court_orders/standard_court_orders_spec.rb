require "rails_helper"

RSpec.describe "Standard Court Orders", type: :system, js: true do
  let(:casa_org) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: casa_org) }
  let(:volunteer) { create(:volunteer, casa_org: casa_org) }

  it "allows an admin to create a standard court order" do
    sign_in admin

    visit edit_casa_org_path(casa_org)
    click_link "New Standard Court Order"
    fill_in "Standard Court Order", with: "Substance Abuse Treatment (child, mother, father, other guardian)"
    click_button "Submit"

    expect(page).to have_css("h1", text: "Editing CASA Organization")
    expect(page).to have_css("div.alert", text: "Standard court order was successfully created.")
    expect(page).to have_css("tr", text: "Substance Abuse Treatment (child, mother, father, other guardian)")
  end

  it "allows an admin to delete a standard court order" do
    sign_in admin

    create(:standard_court_order, value: "Substance Abuse Treatment (child, mother, father, other guardian)")

    visit edit_casa_org_path(casa_org)
  
    within("#standard-court-orders") do
      click_button "Actions Menu"
      click_link "Delete"
    end

    click_link "Delete Standard Court Order"

    expect(page).to have_css("h1", text: "Editing CASA Organization")
    expect(page).to have_css("div.alert", text: "Standard court order was successfully deleted.")
    expect(page).to_not have_css("tr", text: "Substance Abuse Treatment (child, mother, father, other guardian)")
  end

  it "allows a volunteer to select a standard court order" do
    # 
  end
end
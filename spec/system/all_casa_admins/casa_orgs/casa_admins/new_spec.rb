require "rails_helper"

RSpec.describe "all_casa_admins/casa_orgs/casa_admins/new", :disable_bullet, type: :system do
  let(:all_casa_admin) { create(:all_casa_admin, email: "theexample@example.com") }
  let(:organization) { create(:casa_org, name: "Cool CASA") }
  let(:path) { all_casa_admins_casa_org_path(id: organization.id) }

  it "validates and creates new admin" do
    visit path
    expect(page).to have_content "You need to sign in before continuing."

    sign_in all_casa_admin
    visit path
    expect(page).to have_content "Administrators"
    click_on "New CASA Admin"
    expect(page).to have_content "New CASA Admin for Cool CASA"

    click_button "Submit"
    expect(page).to have_content "2 errors prohibited this Casa admin from being saved:"
    expect(page).to have_content "Email can't be blank"
    expect(page).to have_content "Display name can't be blank"

    fill_in "Email", with: "invalid email"
    fill_in "Display name", with: "Freddy"
    click_button "Submit"
    expect(page).to have_content "1 error prohibited this Casa admin from being saved:"
    expect(page).to have_content "Email is invalid"

    fill_in "Email", with: "valid@example.com"
    fill_in "Display name", with: "Freddy Valid"
    click_button "Submit"
    expect(page).to have_content "New admin created successfully"
    expect(page).to have_content "valid@example.com"

    click_on "New CASA Admin"
    fill_in "Email", with: "valid@example.com"
    fill_in "Display name", with: "Freddy Valid"
    click_button "Submit"
    expect(page).to have_content "Email has already been taken"

    expect(CasaAdmin.find_by(email: "valid@example.com").invitation_created_at).not_to be_nil
  end
end

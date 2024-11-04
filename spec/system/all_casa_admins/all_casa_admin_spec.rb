require "rails_helper"

RSpec.describe "all_casa_admins/casa_orgs/casa_admins/new", type: :system do
  it "requires login" do
    visit new_all_casa_admins_casa_org_path
    expect(page).to have_content "You need to sign in before continuing."
    expect(page).to have_current_path "/all_casa_admins/sign_in", ignore_query: true

    visit all_casa_admins_casa_org_path(id: create(:casa_org).id)
    expect(page).to have_current_path "/all_casa_admins/sign_in", ignore_query: true
    expect(page).to have_content "You need to sign in before continuing."
  end

  it "does not allow logged in non all casa admin" do
    casa_admin = create(:casa_admin)
    sign_in casa_admin
    visit new_all_casa_admins_casa_org_path
    expect(page).to have_current_path "/all_casa_admins/sign_in", ignore_query: true
    expect(page).to have_text "You need to sign in before continuing."
    visit "/"
    expect(page).to have_current_path "/supervisors", ignore_query: true
    expect(page).to have_text "Sign Out"
  end

  it "login and create new CasaOrg and new CasaAdmin for CasaOrg" do
    all_casa_admin = create(:all_casa_admin)
    sign_in all_casa_admin

    visit "/"
    expect(page).to have_text "All CASA Admin"
    expect(page).to have_text "New CASA Organization"
    expect(page).to have_text "New All CASA Admin"
    expect(page).to have_text "CASA Organizations"

    # left sidebar
    expect(page).to have_text "Patch Notes"
    expect(page).to have_text "Edit Profile"
    expect(page).to have_text "Feature Flags"
    expect(page).to have_text "Log Out"

    # footer
    expect(page).to have_link("Ruby For Good", href: "https://rubyforgood.org/")
    expect(page).to have_link("Report a site issue", href: "https://form.typeform.com/to/iXY4BubB")
    expect(page).to have_link("SMS Terms & Conditions", href: "/sms-terms-conditions.html")

    # create new org
    click_on "New CASA Organization"
    expect(page).to have_current_path "/all_casa_admins/casa_orgs/new", ignore_query: true
    expect(page).to have_text "Create a new CASA Organization"
    fill_in "Name", with: "Cool Org Name"
    fill_in "Display name", with: "display name"
    fill_in "Address", with: "123 Main St"
    click_on "Create CASA Organization"
    expect(page).to have_text "CASA Organization was successfully created."
    organization = CasaOrg.find_by(name: "Cool Org Name")
    expect(page).to have_current_path "/all_casa_admins/casa_orgs/#{organization.id}", ignore_query: true
    expect(page).to have_content "Administrators"
    expect(page).to have_content "Details"
    expect(page).to have_content "Number of admins: 0"
    expect(page).to have_content "Number of supervisors: 0"
    expect(page).to have_content "Number of active volunteers: 0"
    expect(page).to have_content "Number of inactive volunteers: 0"
    expect(page).to have_content "Number of active cases: 0"
    expect(page).to have_content "Number of inactive cases: 0"
    expect(page).to have_content "Number of all case contacts including inactives: 0"
    expect(page).to have_content "Number of active supervisor to volunteer assignments: 0"
    expect(page).to have_content "Number of active case assignments: 0"

    # create new admin
    click_on "New CASA Admin"
    expect(page).to have_content "New CASA Admin for Cool Org Name"

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

  it "edits all casa admins" do
    admin = create(:all_casa_admin)
    other_admin = create(:all_casa_admin)

    sign_in admin
    visit edit_all_casa_admins_path

    # validate email uniqueness
    fill_in "all_casa_admin_email", with: other_admin.email
    click_on "Update Profile"
    expect(page).to have_text "already been taken"

    # update email
    fill_in "all_casa_admin_email", with: "newemail@example.com"
    click_on "Update Profile"
    expect(page).to have_text "successfully updated"
    expect(ActionMailer::Base.deliveries.last.body.encoded).to match(">We're contacting you to notify you that your email has been changed to newemail@example.com")

    # change password
    click_on "Change Password"
    fill_in "all_casa_admin_password", with: "newpassword"
    fill_in "all_casa_admin_password_confirmation", with: "badmatch"
    click_on "Update Password"
    expect(page).to have_text "confirmation doesn't match"

    click_on "Change Password"
    fill_in "all_casa_admin_password", with: "newpassword"
    fill_in "all_casa_admin_password_confirmation", with: "newpassword"
    click_on "Update Password"
    expect(page).to have_text "Password was successfully updated."
    expect(ActionMailer::Base.deliveries.last.body.encoded).to match("Your CASA password has been changed.")
  end

  it "admin invitations expire" do
    all_casa_admin = AllCasaAdmin.invite!(email: "valid@email.com")
    travel 2.days
    expect(all_casa_admin.valid_invitation?).to be true
    travel 8.days
    expect(all_casa_admin.valid_invitation?).to be false
  end
end

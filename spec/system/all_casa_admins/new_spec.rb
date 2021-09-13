require "rails_helper"

RSpec.describe "all_casa_admins/new", type: :system do
  let(:all_casa_admin) { create(:all_casa_admin, email: "theexample@example.com") }
  let(:path) { authenticated_all_casa_admin_root_path }

  it "validates and creates new all casa admin" do
    sign_in all_casa_admin
    visit path
    expect(page).to have_content "All CASA Admin"
    click_on "New All CASA Admin"
    expect(page).to have_content "New All CASA Admin"

    click_button "Submit"
    expect(page).to have_content "1 error prohibited this All casa admin from being saved:"
    expect(page).to have_content "Email can't be blank"

    fill_in "Email", with: "invalid email"
    click_button "Submit"
    expect(page).to have_content "1 error prohibited this All casa admin from being saved:"
    expect(page).to have_content "Email is invalid"

    fill_in "Email", with: "valid@example.com"
    click_button "Submit"
    expect(page).to have_content "New All CASA admin created successfully"

    click_on "New All CASA Admin"
    fill_in "Email", with: "valid@example.com"
    click_button "Submit"
    expect(page).to have_content "Email has already been taken"

    expect(AllCasaAdmin.find_by(email: "valid@example.com").invitation_created_at).not_to be_nil
  end

  describe "invitation should be" do
    it "valid within expiration period" do
      all_casa_admin = AllCasaAdmin.invite!(email: "valid@email.com")

      travel 2.days

      expect(all_casa_admin.valid_invitation?).to be true
    end

    it "invalid when past expiration date" do
      all_casa_admin = AllCasaAdmin.invite!(email: "valid@email.com")

      travel 8.days

      expect(all_casa_admin.valid_invitation?).to be false
    end
  end
end

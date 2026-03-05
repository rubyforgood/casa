require "rails_helper"

RSpec.describe "volunteers/new", type: :system do
  context "when supervisor" do
    let(:supervisor) { create(:supervisor) }

    it "creates a new volunteer", :js do
      sign_in supervisor
      visit new_volunteer_path

      fill_in "Email", with: "new_volunteer2@example.com"
      fill_in "Display name", with: "New Volunteer Display Name 2"
      fill_in "Date of birth", with: Date.new(2000, 1, 2)

      click_on "Create Volunteer"

      visit volunteers_path
      expect(page).to have_text("New Volunteer Display Name 2")
      expect(page).to have_text("new_volunteer2@example.com")
      expect(page).to have_text("Active")
    end
  end

  context "volunteer user" do
    it "redirects the user with an error message" do
      volunteer = create(:volunteer)
      sign_in volunteer

      visit new_volunteer_path

      expect(page).to have_selector(".alert", text: "Sorry, you are not authorized to perform this action.")
    end

    it "displays learning hour topic when enabled", :js do
      organization = create(:casa_org, learning_topic_active: true)
      volunteer = create(:volunteer, casa_org: organization)
  
      sign_in volunteer
      visit new_learning_hour_path
      expect(page).to have_text("Learning Topic")
    end

    it "does not display learning hour topic when disabled", :js do
      organization = create(:casa_org)
      volunteer = create(:volunteer, casa_org: organization)
  
      sign_in volunteer
      visit new_learning_hour_path
      expect(page).not_to have_text("Learning Topic")
    end
  end
end

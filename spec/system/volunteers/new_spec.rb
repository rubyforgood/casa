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

      click_on "Create volunteer"

      visit volunteers_path
      expect(page).to have_text("New Volunteer Display Name 2")
      expect(page).to have_text("new_volunteer2@example.com")
      expect(page).to have_text("Active")
    end

    it "saves the optional mailing address when provided" do
      sign_in supervisor
      visit new_volunteer_path

      fill_in "Email", with: "addressed_volunteer@example.com"
      fill_in "Display name", with: "Addressed Volunteer"
      fill_in "Address line 1", with: "123 Main St"
      fill_in "City", with: "Springfield"
      fill_in "State", with: "IL"
      fill_in "ZIP", with: "62704"

      click_on "Create volunteer"

      address = Volunteer.find_by(email: "addressed_volunteer@example.com").address
      expect(address.line_1).to eq "123 Main St"
      expect(address.city).to eq "Springfield"
    end

    it "leaves no address record when the optional address is left blank" do
      sign_in supervisor
      visit new_volunteer_path

      fill_in "Email", with: "no_address@example.com"
      fill_in "Display name", with: "No Address"

      click_on "Create volunteer"

      expect(Volunteer.find_by(email: "no_address@example.com").address).to be_nil
    end

    it "shows a design-system error when a required field is blank" do
      sign_in supervisor
      visit new_volunteer_path

      fill_in "Email", with: "missing_name@example.com"
      # Display name (required) left blank

      click_on "Create volunteer"

      expect(page).to have_selector("#error_explanation", text: "Unable to save")
      expect(page).to have_selector("#error_explanation", text: /Display name.*blank/)
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
      organization = build(:casa_org, learning_topic_active: true)
      volunteer = create(:volunteer, casa_org: organization)

      sign_in volunteer
      visit new_learning_hour_path
      expect(page).to have_text("Learning topic")
    end

    it "does not display learning hour topic when disabled", :js do
      organization = build(:casa_org)
      volunteer = create(:volunteer, casa_org: organization)

      sign_in volunteer
      visit new_learning_hour_path
      expect(page).not_to have_text("Learning topic")
    end
  end
end

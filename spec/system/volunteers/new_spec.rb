require "rails_helper"

RSpec.describe "volunteers/new", type: :system do
  context "when admin" do
    let(:admin) { create(:casa_admin) }

    it "creates a new volunteer and sends invitation" do
      sign_in admin
      visit new_volunteer_path

      fill_in "Email", with: "new_volunteer@example.com"
      fill_in "Display name", with: "New Volunteer Display Name"
      fill_in "Date of birth", with: "08/08/2001"

      click_on "Create Volunteer"

      last_email = ActionMailer::Base.deliveries.last
      expect(last_email.to).to eq ["new_volunteer@example.com"]
      expect(last_email.subject).to have_text "CASA Console invitation instructions"
      expect(last_email.html_part.body.encoded).to have_text "your new Volunteer account."
      expect(Volunteer.find_by(email: "new_volunteer@example.com").invitation_created_at).not_to be_nil
    end
  end

  context "when supervisor" do
    let(:supervisor) { create(:supervisor) }

    it "lets Supervisor create new volunteer" do
      sign_in supervisor
      visit new_volunteer_path

      fill_in "Email", with: "new_volunteer2@example.com"
      fill_in "Display name", with: "New Volunteer Display Name 2"
      fill_in "Date of birth", with: "01/01/2000"

      expect do
        click_on "Create Volunteer"
      end.to change(User, :count).by(1)
    end
  end

  context "volunteer user" do
    let(:volunteer) { create(:volunteer) }

    before { sign_in volunteer }

    it "redirects the user with an error message" do
      visit new_volunteer_path

      expect(page).to have_selector(".alert", text: "Sorry, you are not authorized to perform this action.")
    end
  end

  it "displays learning hour topic for volunteers when enabled", js: true do
    organization = create(:casa_org, learning_topic_active: true)
    volunteer = create(:volunteer, casa_org: organization)

    sign_in volunteer
    visit new_learning_hour_path
    expect(page).to have_text("Learning Topic")
  end

  it "learning hour topic hidden when disabled", js: true do
    organization = create(:casa_org)
    volunteer = create(:volunteer, casa_org: organization)

    sign_in volunteer
    visit new_learning_hour_path
    expect(page).to_not have_text("Learning Topic")
  end
end

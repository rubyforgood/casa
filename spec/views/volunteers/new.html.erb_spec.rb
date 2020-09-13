require "rails_helper"

describe "volunteers/new" do
  subject { render template: "volunteers/new" }
  before do
    assign :volunteer, Volunteer.new
  end

  context "while signed in as admin" do
    before do
      sign_in_as_admin
      # visit new_volunteer_path
    end

    it { is_expected.to have_selector("a", text: "Return to Dashboard") }
    it { is_expected.to have_selector("a", text: "Create User")}
    it "should display two error messages when blank fields are submitted" do
      click_button "Create User"
      expect(page).to have_text "Email can't be blank"
      expect(page).to have_text "Display name can't be blank"
    end
  end
end

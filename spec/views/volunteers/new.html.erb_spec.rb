require "rails_helper"

describe "volunteers/new" do
  subject { render template: "volunteers/new" }
  before do
    assign :volunteer, Volunteer.new
  end

  context "while signed in as admin" do
    before do
      $stderr.puts("Casa Admin")
      $stderr.puts(CasaAdmin.first)
      sign_in_as_admin
      visit new_volunteer_path
    end

    it { is_expected.to have_selector("a", text: "Return to Dashboard") }
    
    it "should display two error messages when blank fields are submitted" do
      click "Create User"
      expect(page.contains "Email can't be blank")
      expect(page.contains "Display name can't be blank")
    end
  end
end

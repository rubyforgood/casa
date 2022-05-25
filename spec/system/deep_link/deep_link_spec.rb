require "rails_helper"

RSpec.describe "deep_link", type: :system do
  context "when user recieves a deep link" do
    let(:volunteer) { create(:volunteer) }

    it "redirects to current url for a GET" do
      visit "/users/edit"
      fill_in "Email", with: volunteer.email
      fill_in "Password", with: "12345678"
      within ".actions" do
        click_on "Log in"
      end
      expect(current_path).to eq "/users/edit"
      expect(page).to have_text "Edit Profile"
    end
  end
end

require "rails_helper"

RSpec.describe "banners/dismiss", :js, type: :system do
  let!(:casa_org) { create(:casa_org) }
  let!(:active_banner) { create(:banner, casa_org: casa_org) }
  let(:volunteer) { create(:volunteer, casa_org: casa_org) }

  context "when user dismisses a banner" do
    it "hides banner" do
      sign_in volunteer

      visit root_path
      expect(page).to have_text("Please fill out this survey")

      click_on "Dismiss"
      expect(page).to have_no_text("Please fill out this survey")
    end
  end
end

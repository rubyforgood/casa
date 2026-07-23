require "rails_helper"

RSpec.describe "chapter analytics", type: :system do
  let(:organization) { create(:casa_org) }

  context "as an admin" do
    before { sign_in create(:casa_admin, casa_org: organization) }

    it "is reachable from the sidebar and shows KPI cards plus charts" do
      visit authenticated_user_root_path
      expect(page).to have_link("Analytics")

      click_link "Analytics"

      expect(page).to have_current_path(analytics_path, ignore_query: true)
      expect(page).to have_css("h1", text: "Analytics")
      expect(page).to have_text("Contacts this month")
      expect(page).to have_text("Cases needing contact")
      expect(page).to have_text("Case contacts logged")
    end
  end

  context "as a supervisor" do
    before { sign_in create(:supervisor, casa_org: organization) }

    it "can reach the analytics page" do
      visit analytics_path
      expect(page).to have_css("h1", text: "Analytics")
    end
  end

  context "as a volunteer" do
    before { sign_in create(:volunteer, casa_org: organization) }

    it "does not show the Analytics nav link" do
      visit authenticated_user_root_path
      expect(page).to have_no_link("Analytics")
    end
  end
end

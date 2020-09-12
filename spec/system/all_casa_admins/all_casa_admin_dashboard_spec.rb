require "rails_helper"

RSpec.describe "all_casa_admin_dashboard_spec", type: :system do
  let(:all_casa_admin) { create(:all_casa_admin) }
  let(:volunteer) { create(:volunteer) }
  let!(:casa_org) { create(:casa_org) }

  context "when authenticated user" do
    before { sign_in all_casa_admin }

    it "renders AllCasaAdmin dashboard page" do
      visit "/"
      expect(page).to have_text "All CASA Admin"
      expect(page).to have_text casa_org.name
    end
  end
end

require "rails_helper"

RSpec.describe "static/index", type: :system do
  context "when visiting the CASA volunteer landing page", js: true do
    describe "when all organizations have logos" do
      before do
        3.times { create(:casa_org, :with_logo) }
        visit root_path
      end

      it "has CASA organizations section" do
        expect(page).to have_text "CASA Organizations Powered by Our App"
      end

      it "displays all organizations that have attached logos" do
        within("#organizations") do
          expect(page).to have_css(".org_logo", count: 3)
        end
      end
    end

    describe "when some orgs are missing logos" do
      before do
        4.times { create(:casa_org, :with_logo) }
        4.times { create(:casa_org) }
        visit root_path
      end

      it "does not display organizations that don't have attached logos" do
        within("#organizations") do
          expect(page).to have_css(".org_logo", count: 4)
        end
      end
    end
  end
end

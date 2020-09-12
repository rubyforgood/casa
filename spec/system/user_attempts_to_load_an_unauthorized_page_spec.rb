require "rails_helper"

RSpec.describe "user attempts to load an unauthorized page", type: :system do
  let(:organization) { create(:casa_org) }
  let(:volunteer) { create(:volunteer, casa_org: organization) }

  context "as a volunteer" do
    before { sign_in volunteer }

    describe "new supervisor page" do
      it "redirects the user with an error message" do
        visit new_supervisor_path

        expect(page).to have_current_path("/")
        expect(page).to have_selector(".alert", text: "Sorry, you are not authorized to perform this action.")
      end
    end

    describe "imports page" do
      it "redirects the user with an error message" do
        visit imports_path

        expect(page).to have_current_path("/")
        expect(page).to have_selector(".alert", text: "Sorry, you are not authorized to perform this action.")
      end
    end
  end
end

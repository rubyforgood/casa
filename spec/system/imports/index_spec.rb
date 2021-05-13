require "rails_helper"

RSpec.describe "imports/index", :disable_bullet, type: :system do
  let(:volunteer) { create(:volunteer) }

  context "as a volunteer" do
    before { sign_in volunteer }

    it "redirects the user with an error message" do
      visit imports_path

      expect(page).to have_selector(".alert", text: "Sorry, you are not authorized to perform this action.")
    end
  end
end

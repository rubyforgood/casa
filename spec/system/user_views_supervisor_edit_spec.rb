require "rails_helper"

RSpec.describe "view supervisor edit", type: :system do
  context "when the current user is a supervisor" do
    it "does not have a submit button", js: false do
      current_supervisor = create(:supervisor)
      other_supervisor = create(:supervisor)

      sign_in current_supervisor
      visit edit_supervisor_path(other_supervisor)

      expect(page).not_to have_selector(:link_or_button, "Submit")
    end

    context "when the current user is editing self", js: false do
      it "displays a submit button" do
        current_supervisor = create(:supervisor)

        sign_in current_supervisor
        visit edit_supervisor_path(current_supervisor)

        expect(page).to have_selector(:link_or_button, "Submit")
      end
    end
  end

  context "when the current user is an admin" do
    it "displays a submit button", js: false do
      admin = create(:casa_admin)
      supervisor = create(:supervisor)

      sign_in admin
      visit edit_supervisor_path(supervisor)

      expect(page).to have_selector(:link_or_button, "Submit")
    end
  end
end

require "rails_helper"

RSpec.describe "all_casa_admins/patch_notes/index", type: :system do
  context "the new patch note form" do
    let(:all_casa_admin) { build_stubbed(:all_casa_admin) }

    context "when the new patch note form's textarea is blank" do
      it "displays a warning after trying to create", js: true do
        sign_in all_casa_admin
        visit all_casa_admins_patch_notes_path

        within "#new-patch-note" do
          click_on "Create"
        end

        expect(page).to have_selector(".async-warn-indicator", text: "Cannot save an empty patch note")
      end
    end
  end
end

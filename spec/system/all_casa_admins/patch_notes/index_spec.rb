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

    context "when the patch note form is filled out" do
      let(:patch_note_text) { "2y]@WX\\lBI:c,j," }
      let!(:patch_note_group) { create(:patch_note_type, :all_users) }
      let!(:patch_note_type) { create(:patch_note_type, name: "5[1ht=d\\%*^qRON") }

      it "displays a the new patch note on the page", js: true do
        sign_in all_casa_admin
        visit all_casa_admins_patch_notes_path

        within "#new-patch-note" do
          text_area = first(:css, "#new-patch-note textarea").native
          text_area.send_keys(patch_note_text)

          click_on "Create"

          wait_for_ajax

          expect(page).to have_css(".patch-note-list-item.card.new textarea", text: patch_note_text)
        end
      end
    end
  end
end

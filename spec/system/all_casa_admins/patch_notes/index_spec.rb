require "rails_helper"

RSpec.describe "all_casa_admins/patch_notes/index", type: :system do
  let(:all_casa_admin) { create(:all_casa_admin) }

  context "the new patch note form" do
    context "when the new patch note form's textarea is blank" do
      it "displays a warning after trying to create", :js do
        sign_in all_casa_admin
        visit all_casa_admins_patch_notes_path

        within "#new-patch-note" do
          click_on "Create"
        end

        expect(page).to have_selector(".warning-notification", text: "Cannot save an empty patch note")
      end
    end

    context "when the patch note form is filled out" do
      let(:patch_note_text) { "/6cg0lad1P/NFtV" }
      let!(:patch_note_group) { create(:patch_note_group, :all_users) }
      let!(:patch_note_type) { create(:patch_note_type, name: "5[1ht=d\\\\%*^qRON") }

      it "displays the new patch note text on the page", :js do
        sign_in all_casa_admin
        visit all_casa_admins_patch_notes_path

        expect(page).to have_text("Patch notes")
        within "#new-patch-note" do
          find("textarea").set(patch_note_text)

          click_on "Create"
        end

        expect(page).to have_text("Patch notes")

        expect(page.find(".patch-note-list-item.new textarea")&.value).to eq(patch_note_text)
      end
    end
  end

  context "an existing patch note" do
    let!(:patch_note) { create(:patch_note, note: "original note") }

    it "can be edited and saved without a page reload", :js do
      sign_in all_casa_admin
      visit all_casa_admins_patch_notes_path

      within "#patch-note-#{patch_note.id}" do
        click_on "Edit"

        textarea = find("textarea")
        expect(textarea).not_to be_disabled
        textarea.set("edited note")

        click_on "Save"
      end

      within "#patch-note-#{patch_note.id}" do
        textarea = find("textarea")
        expect(textarea).to be_disabled
        expect(textarea.value).to eq("edited note")
      end
      expect(patch_note.reload.note).to eq("edited note")
    end

    it "restores the original values when edit is cancelled", :js do
      sign_in all_casa_admin
      visit all_casa_admins_patch_notes_path

      within "#patch-note-#{patch_note.id}" do
        click_on "Edit"
        find("textarea").set("unsaved changes")
        click_on "Cancel"
      end

      within "#patch-note-#{patch_note.id}" do
        textarea = find("textarea")
        expect(textarea).to be_disabled
        expect(textarea.value).to eq("original note")
      end
      expect(patch_note.reload.note).to eq("original note")
    end

    it "can be deleted (after the 3-click confirm) without a page reload", :js do
      sign_in all_casa_admin
      visit all_casa_admins_patch_notes_path

      within "#patch-note-#{patch_note.id}" do
        click_on "Delete"
        click_on "2"
        click_on "1"
      end

      expect(page).not_to have_selector("#patch-note-#{patch_note.id}")
      expect(PatchNote.exists?(patch_note.id)).to eq(false)
    end
  end
end

require "rails_helper"

RSpec.describe "followups/create", :js, type: :system do
  let(:admin) { create(:casa_admin) }
  let(:case_contact) { create(:case_contact) }
  let(:note) { "Lorem ipsum dolor sit amet." }

  describe "Creating a followup" do
    before do
      sign_in admin
      visit casa_case_path(case_contact.casa_case)

      click_button "Make reminder"
    end

    it "opens the reminder dialog" do
      expect(page).to have_text("Optional: add a note about what followup is needed")
    end

    context "when confirming" do
      it "creates a followup with the note when it is filled in" do
        within("dialog[open]") do
          fill_in "note", with: note
          click_button "Confirm"
        end

        expect(page).to have_button("Resolve reminder")
        expect(case_contact.followups.reload.count).to eq(1)
        expect(case_contact.followups.last.note).to eq(note)
      end

      it "creates a followup with no note when it is left empty" do
        within("dialog[open]") { click_button "Confirm" }

        expect(page).to have_button("Resolve reminder")
        expect(case_contact.followups.reload.count).to eq(1)
        expect(case_contact.followups.last.note).to be_nil
      end
    end

    context "when dismissing" do
      it "creates no followup on Cancel" do
        within("dialog[open]") do
          fill_in "note", with: note
          click_button "Cancel"
        end

        expect(case_contact.followups.reload.count).to be_zero
      end

      it "creates no followup when closed" do
        find("dialog[open] button[aria-label='Close']").click

        expect(case_contact.followups.reload.count).to be_zero
      end
    end
  end
end

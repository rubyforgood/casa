require "rails_helper"

RSpec.describe "followups/create", :js, type: :system do
  let(:admin) { create(:casa_admin) }
  let(:case_contact) { create(:case_contact) }
  let(:note) { "Lorem ipsum dolor sit amet." }

  describe "Creating a followup" do
    before do
      sign_in admin
      visit casa_case_path(case_contact.casa_case)

      click_button "Make Reminder"
    end

    it "displays correct prompt" do
      expect(page).to have_content("Optional: Add a note about what followup is needed.")
    end

    context "when confirming the Swal alert" do
      it "creates a followup with a note when the note textarea is filled" do
        find(".swal2-textarea").set(note)

        click_button "Confirm"

        expect(page).to have_button("Resolve Reminder")

        case_contact.followups.reload

        expect(case_contact.followups.count).to eq(1)
        expect(case_contact.followups.last.note).to eq(note)
      end

      it "creates a followup without a note when the note textarea is empty" do
        click_button "Confirm"

        expect(page).to have_button("Resolve Reminder")

        case_contact.followups.reload

        expect(case_contact.followups.count).to eq(1)
        expect(case_contact.followups.last.note).to be_nil
      end
    end

    context "when cancelling the Swal alert" do
      it "does nothing when there is text in the note textarea" do
        find(".swal2-textarea").set(note)

        click_button "Cancel"

        expect(case_contact.followups.reload.count).to be_zero
      end

      it "does nothing when there is no text in the note textarea" do
        click_button "Cancel"

        expect(case_contact.followups.reload.count).to be_zero
      end
    end

    context "when closing the Swal alert" do
      it "does nothing when there is text in the note textarea" do
        find(".swal2-textarea").set(note)

        find(".swal2-close").click

        expect(case_contact.followups.reload.count).to be_zero
      end

      it "does nothing when there is no text in the note textarea" do
        find(".swal2-close").click

        expect(case_contact.followups.reload.count).to be_zero
      end
    end
  end
end

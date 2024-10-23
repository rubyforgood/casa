require "rails_helper"

RSpec.describe "volunteers/notes/edit", type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org_id: organization.id) }
  let(:volunteer) { create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id) }
  let(:note) { volunteer.notes.create(creator: admin, content: "Good job.") }

  context "when logged in as an admin" do
    before do
      sign_in admin
      visit edit_volunteer_note_path(volunteer, note)
    end

    scenario "editing an existing note" do
      expect(page).to have_text("Good job.")

      fill_in("note[content]", with: "Great job!")

      click_on("Update Note")

      expect(page).to have_current_path edit_volunteer_path(volunteer), ignore_query: true

      expect(page).to have_text("Great job!")

      expect(note.reload.content).to eq "Great job!"
    end
  end
end

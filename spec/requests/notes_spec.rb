require "rails_helper"

RSpec.describe "/volunteers/notes", type: :request do
  describe "POST /create" do
    context "when logged in as admin" do
      it "can create a note for volunteer in same organization" do
        organization = create(:casa_org)
        admin = create(:casa_admin, casa_org: organization)
        volunteer = create(:volunteer, :with_assigned_supervisor, casa_org: organization)
        sign_in admin
        expect {
          post volunteer_notes_path(volunteer), params: {note: {content: "Very nice!"}}
        }.to change(Note, :count).by(1)
        expect(response).to redirect_to edit_volunteer_path(volunteer)
        expect(Note.last.content).to eq "Very nice!"
      end

      it "cannot create a note for volunteer in different organization" do
        organization = create(:casa_org)
        other_organization = create(:casa_org)
        admin = create(:casa_admin, casa_org: organization)
        volunteer = create(:volunteer, casa_org: other_organization)

        sign_in admin
        expect {
          post volunteer_notes_path(volunteer), params: {note: {content: "Very nice!"}}
        }.not_to change(Note, :count)
        expect(response).to redirect_to root_path
      end
    end

    context "when logged in as a supervisor" do
      it "can create a note for volunteer in same organization" do
        organization = create(:casa_org)
        supervisor = create(:supervisor, casa_org: organization)
        volunteer = create(:volunteer, :with_assigned_supervisor, casa_org: organization)
        sign_in supervisor
        expect {
          post volunteer_notes_path(volunteer), params: {note: {content: "Very nice!"}}
        }.to change(Note, :count).by(1)
        expect(response).to redirect_to edit_volunteer_path(volunteer)
        expect(Note.last.content).to eq "Very nice!"
      end

      it "cannot create a note for volunteer in different organization" do
        organization = create(:casa_org)
        other_organization = create(:casa_org)
        supervisor = create(:supervisor, casa_org: organization)
        volunteer = create(:volunteer, casa_org: other_organization)

        sign_in supervisor
        expect {
          post volunteer_notes_path(volunteer), params: {note: {content: "Very nice!"}}
        }.not_to change(Note, :count)
        expect(response).to redirect_to root_path
      end
    end

    context "when logged in as volunteer" do
      it "cannot create a note" do
        organization = create(:casa_org)
        volunteer = create(:volunteer, :with_assigned_supervisor, casa_org: organization)

        sign_in volunteer
        expect {
          post volunteer_notes_path(volunteer), params: {note: {content: "Very nice!"}}
        }.not_to change(Note, :count)
        expect(response).to redirect_to root_path
      end
    end
  end

  describe "GET /edit" do
    context "when logged in as admin" do
      context "when volunteer in same organization" do
        it "is successful if note belongs to volunteer" do
          organization = create(:casa_org)
          admin = create(:casa_admin, casa_org: organization)
          volunteer = create(:volunteer, :with_assigned_supervisor, casa_org: organization)
          note = create(:note, notable: volunteer)

          sign_in admin
          get edit_volunteer_note_path(volunteer, note)

          expect(response).to be_successful
        end

        it "redirects to root path if note does not belong to volunteer" do
          organization = create(:casa_org)
          admin = create(:casa_admin, casa_org: organization)
          volunteer = create(:volunteer, :with_assigned_supervisor, casa_org: organization)
          other_volunteer = create(:volunteer, :with_assigned_supervisor, casa_org: organization)
          note = create(:note, notable: other_volunteer)

          sign_in admin
          get edit_volunteer_note_path(volunteer, note)

          expect(response).to redirect_to root_path
        end
      end

      context "when volunteer in different organization" do
        it "redirects to root path" do
          organization = create(:casa_org)
          other_organization = create(:casa_org)
          admin = create(:casa_admin, casa_org: organization)

          volunteer = create(:volunteer, casa_org: other_organization)
          note = create(:note, notable: volunteer)

          sign_in admin
          get edit_volunteer_note_path(volunteer, note)

          expect(response).to redirect_to root_path
        end
      end
    end

    context "when logged in as supervisor" do
      context "when volunteer in same organization" do
        it "is successful if note belongs to volunteer" do
          organization = create(:casa_org)
          supervisor = create(:supervisor, casa_org: organization)
          volunteer = create(:volunteer, :with_assigned_supervisor, casa_org: organization)
          note = create(:note, notable: volunteer)

          sign_in supervisor
          get edit_volunteer_note_path(volunteer, note)

          expect(response).to be_successful
        end

        it "redirects to root path if note does not belong to volunteer" do
          organization = create(:casa_org)
          supervisor = create(:supervisor, casa_org: organization)
          volunteer = create(:volunteer, :with_assigned_supervisor, casa_org: organization)
          other_volunteer = create(:volunteer, :with_assigned_supervisor, casa_org: organization)
          note = create(:note, notable: other_volunteer)

          sign_in supervisor
          get edit_volunteer_note_path(volunteer, note)

          expect(response).to redirect_to root_path
        end
      end

      context "when volunteer in different organization" do
        it "redirects to root path" do
          organization = create(:casa_org)
          other_organization = create(:casa_org)
          supervisor = create(:supervisor, casa_org: organization)

          volunteer = create(:volunteer, casa_org: other_organization)
          note = create(:note, notable: volunteer)

          sign_in supervisor
          get edit_volunteer_note_path(volunteer, note)

          expect(response).to redirect_to root_path
        end
      end
    end

    context "when logged in as volunteer" do
      context "when note belongs to volunteer" do
        it "redirects to root path" do
          organization = create(:casa_org)
          volunteer = create(:volunteer, :with_assigned_supervisor, casa_org: organization)
          note = create(:note, notable: volunteer)

          sign_in volunteer
          get edit_volunteer_note_path(volunteer, note)

          expect(response).to redirect_to root_path
        end
      end
    end
  end

  describe "PATCH /update" do
    context "when logged in as an admin" do
      context "when volunteer in same org" do
        it "updates note and redirects to edit volunteer page" do
          organization = create(:casa_org)
          admin = create(:casa_admin, casa_org: organization)
          volunteer = create(:volunteer, :with_assigned_supervisor, casa_org: organization)
          note = create(:note, notable: volunteer, creator: admin, content: "Good job.")

          sign_in admin
          patch volunteer_note_path(volunteer, note), params: {note: {content: "Very nice!"}}

          expect(response).to redirect_to(edit_volunteer_path(volunteer))
          expect(note.reload.content).to eq "Very nice!"
        end
      end

      context "when volunteer in different org" do
        it "does not update note and redirects to root path" do
          organization = create(:casa_org)
          other_organization = create(:casa_org)
          admin = create(:casa_admin, casa_org: organization)
          volunteer = create(:volunteer, casa_org: other_organization)
          note = create(:note, notable: volunteer, content: "Good job.")

          sign_in admin
          patch volunteer_note_path(volunteer, note), params: {note: {content: "Very nice!"}}

          expect(response).to redirect_to root_path
          expect(note.reload.content).to eq "Good job."
        end
      end
    end

    context "when logged in as a supervisor" do
      context "when volunteer in same org" do
        it "updates note and redirects to edit volunteer page" do
          organization = create(:casa_org)
          supervisor = create(:supervisor, casa_org: organization)
          volunteer = create(:volunteer, :with_assigned_supervisor, casa_org: organization)
          note = create(:note, notable: volunteer, content: "Good job.")

          sign_in supervisor
          patch volunteer_note_path(volunteer, note), params: {note: {content: "Very nice!"}}

          expect(response).to redirect_to(edit_volunteer_path(volunteer))
          expect(note.reload.content).to eq "Very nice!"
        end
      end

      context "when volunteer in different org" do
        it "does not update note and redirects to root path" do
          organization = create(:casa_org)
          other_organization = create(:casa_org)
          supervisor = create(:supervisor, casa_org: organization)
          volunteer = create(:volunteer, casa_org: other_organization)
          note = create(:note, notable: volunteer, content: "Good job.")

          sign_in supervisor
          patch volunteer_note_path(volunteer, note), params: {note: {content: "Very nice!"}}

          expect(response).to redirect_to root_path
          expect(note.reload.content).to eq "Good job."
        end
      end
    end

    context "when logged in as a volunteer" do
      context "when updating note belonging to volunteer" do
        it "does not update note and redirects to root path" do
          organization = create(:casa_org)
          volunteer = create(:volunteer, casa_org: organization)
          note = create(:note, notable: volunteer, content: "Good job.")

          sign_in volunteer
          patch volunteer_note_path(volunteer, note), params: {note: {content: "Very nice!"}}

          expect(response).to redirect_to root_path
          expect(note.reload.content).to eq "Good job."
        end
      end
    end
  end

  describe "DELETE /destroy" do
    context "when logged in as an admin" do
      it "can delete notes about a volunteer in same organization" do
        organization = create(:casa_org)
        admin = create(:casa_admin, casa_org: organization)
        volunteer = create(:volunteer, :with_assigned_supervisor, casa_org: organization)
        note = create(:note, notable: volunteer)

        sign_in admin
        expect {
          delete volunteer_note_path(volunteer, note)
        }.to change(Note, :count).by(-1)
        expect(response).to redirect_to edit_volunteer_path(volunteer)
      end

      it "cannot delete notes about a volunteer in different organization" do
        organization = create(:casa_org)
        other_organization = create(:casa_org)
        admin = create(:casa_admin, casa_org: organization)
        volunteer = create(:volunteer, casa_org: other_organization)
        note = create(:note, notable: volunteer)

        sign_in admin
        expect {
          delete volunteer_note_path(volunteer, note)
        }.not_to change(Note, :count)
        expect(response).to redirect_to root_path
      end
    end

    context "when logged in as a supervisor" do
      it "can delete notes about a volunteer in same organization" do
        organization = create(:casa_org)
        supervisor = create(:supervisor, casa_org: organization)
        volunteer = create(:volunteer, :with_assigned_supervisor, casa_org: organization)
        note = create(:note, notable: volunteer)

        sign_in supervisor
        expect {
          delete volunteer_note_path(volunteer, note)
        }.to change(Note, :count).by(-1)
        expect(response).to redirect_to edit_volunteer_path(volunteer)
      end

      it "cannot delete notes about a volunteer in different organization" do
        organization = create(:casa_org)
        other_organization = create(:casa_org)
        supervisor = create(:supervisor, casa_org: organization)
        volunteer = create(:volunteer, casa_org: other_organization)
        note = create(:note, notable: volunteer)

        sign_in supervisor
        expect {
          delete volunteer_note_path(volunteer, note)
        }.not_to change(Note, :count)
        expect(response).to redirect_to root_path
      end
    end

    context "when logged in as a volunteer" do
      it "cannot delete notes" do
        volunteer = create(:volunteer, :with_assigned_supervisor)
        note = create(:note, notable: volunteer)

        sign_in volunteer
        expect {
          delete volunteer_note_path(volunteer, note)
        }.not_to change(Note, :count)
        expect(response).to redirect_to root_path
      end
    end
  end
end

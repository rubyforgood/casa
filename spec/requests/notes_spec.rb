require "rails_helper"

RSpec.describe "/volunteers/notes", type: :request do
  RSpec.shared_examples "create" do
    let(:organization) { create(:casa_org) }

    context "when in the same organization" do
      it "can create a note for volunteer" do
        volunteer = create(:volunteer, :with_assigned_supervisor, casa_org: organization)

        sign_in user

        expect do
          post volunteer_notes_path(volunteer), params: {note: {content: "Very nice!"}}
        end.to change(Note, :count).by(1)
        expect(response).to redirect_to edit_volunteer_path(volunteer)
        expect(Note.last.content).to eq "Very nice!"
      end
    end

    context "when in a different organization" do
      it "cannot create a note for volunteer" do
        other_organization = create(:casa_org)
        volunteer = create(:volunteer, casa_org: other_organization)

        sign_in user

        expect do
          post volunteer_notes_path(volunteer), params: {note: {content: "Very nice!"}}
        end.not_to change(Note, :count)
        expect(response).to redirect_to root_path
      end
    end
  end

  RSpec.shared_examples "edit" do
    let(:organization) { create(:casa_org) }

    context "when in the same organization" do
      let(:volunteer) { create(:volunteer, :with_assigned_supervisor, casa_org: organization) }

      it "is successful if note belongs for volunteer" do
        note = create(:note, notable: volunteer)

        sign_in user
        get edit_volunteer_note_path(volunteer, note)

        expect(response).to be_successful
      end

      it "redirects to root path if note does not belong to volunteer" do
        other_volunteer = create(:volunteer, :with_assigned_supervisor, casa_org: organization)
        note = create(:note, notable: other_volunteer)

        sign_in user
        get edit_volunteer_note_path(volunteer, note)

        expect(response).to redirect_to root_path
      end
    end

    context "when in a different organization" do
      it "redirects to root path" do
        other_organization = create(:casa_org)
        volunteer = create(:volunteer, casa_org: other_organization)
        note = create(:note, notable: volunteer)

        sign_in user
        get edit_volunteer_note_path(volunteer, note)

        expect(response).to redirect_to root_path
      end
    end
  end

  RSpec.shared_examples "update" do
    let(:organization) { create(:casa_org) }

    context "when in the same organization" do
      it "updates note and redirects to edit volunteer page" do
        volunteer = create(:volunteer, :with_assigned_supervisor, casa_org: organization)
        note = create(:note, notable: volunteer, creator: user, content: "Good job.")

        sign_in user
        patch volunteer_note_path(volunteer, note), params: {note: {content: "Very nice!"}}

        expect(response).to redirect_to(edit_volunteer_path(volunteer))
        expect(note.reload.content).to eq "Very nice!"
      end
    end

    context "when in a different organization" do
      it "does not update note and redirects to root path" do
        other_organization = create(:casa_org)
        volunteer = create(:volunteer, casa_org: other_organization)
        note = create(:note, notable: volunteer, content: "Good job.")

        sign_in user
        patch volunteer_note_path(volunteer, note), params: {note: {content: "Very nice!"}}

        expect(response).to redirect_to root_path
        expect(note.reload.content).to eq "Good job."
      end
    end
  end

  RSpec.shared_examples "delete" do
    let(:organization) { create(:casa_org) }

    context "when in the same organization" do
      it "can delete notes about a volunteer" do
        volunteer = create(:volunteer, :with_assigned_supervisor, casa_org: organization)
        note = create(:note, notable: volunteer)

        sign_in user

        expect do
          delete volunteer_note_path(volunteer, note)
        end.to change(Note, :count).by(-1)
        expect(response).to redirect_to edit_volunteer_path(volunteer)
      end
    end

    context "when in a different organization" do
      it "cannot delete notes about a volunteer" do
        other_organization = create(:casa_org)
        volunteer = create(:volunteer, casa_org: other_organization)
        note = create(:note, notable: volunteer)

        sign_in user

        expect do
          delete volunteer_note_path(volunteer, note)
        end.not_to change(Note, :count)
        expect(response).to redirect_to root_path
      end
    end
  end

  describe "POST /create" do
    context "when logged in as admin" do
      it_behaves_like "create" do
        let(:user) { create(:casa_admin, casa_org: organization) }
      end
    end

    context "when logged in as a supervisor" do
      it_behaves_like "create" do
        let(:user) { create(:supervisor, casa_org: organization) }
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
      it_behaves_like "edit" do
        let(:user) { create(:casa_admin, casa_org: organization) }
      end
    end

    context "when logged in as supervisor" do
      it_behaves_like "edit" do
        let(:user) { create(:supervisor, casa_org: organization) }
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
      it_behaves_like "update" do
        let(:user) { create(:casa_admin, casa_org: organization) }
      end
    end

    context "when logged in as a supervisor" do
      it_behaves_like "update" do
        let(:user) { create(:supervisor, casa_org: organization) }
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
      it_behaves_like "delete" do
        let(:user) { create(:casa_admin, casa_org: organization) }
      end
    end

    context "when logged in as a supervisor" do
      it_behaves_like "delete" do
        let(:user) { create(:supervisor, casa_org: organization) }
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

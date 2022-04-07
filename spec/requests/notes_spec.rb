require "rails_helper"

RSpec.describe "/volunteers/notes", type: :request do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org_id: organization.id) }
  let(:volunteer) { create(:volunteer, :with_assigned_supervisor, casa_org_id: organization.id) }
  let(:note) { volunteer.notes.create(creator: admin, content: "Good job.") }

  describe "PATCH /update" do
    subject(:request) { patch volunteer_note_path(volunteer, note), params: params }

    context "when logged in as an admin" do
      before do
        sign_in admin
        request
      end

      context "with valid params" do
        let(:params) { {note: {content: "Very nice!"}} }

        it "returns success response" do
          expect(response).to redirect_to(edit_volunteer_path(volunteer))
          expect(note.reload.content).to eq "Very nice!"
        end
      end
    end
  end
end

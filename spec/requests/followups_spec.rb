require "rails_helper"

RSpec.describe "/followups", type: :request do
  describe "POST /create" do
    let(:admin) { create(:casa_admin) }
    let(:contact) { create(:case_contact) }

    context "with valid parameters" do
      context "no followup exists yet" do
        it "creates a followup" do
          sign_in admin

          expect {
            post followups_path, params: {contact_id: contact.id}
          }.to change(Followup, :count).by(1)
        end
      end

      context "followup exists and is in :requested status" do
        let!(:followup) { create(:followup, case_contact: contact) }

        it "advances the followup to the :resolved status" do
          sign_in admin

          post followups_path, params: {contact_id: contact.id}
          expect(followup.reload.status).to eq("resolved")
        end
      end
    end

    context "with invalid parameters" do
      it "does not create a new Followup" do
        sign_in admin

        expect { post followups_path, params: {contact_id: "nonsense"} }.to change(
          Followup,
          :count
        ).by(0)
      end

      it "redirects to the casa case index view" do
        sign_in admin

        post followups_path, params: {contact_id: "nonsense"}
        expect(response).to redirect_to "/casa_cases"
      end
    end
  end
end

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
            post case_contact_followups_path(contact)
          }.to change(Followup, :count).by(1)
        end
      end

      context "followup exists and is in :requested status" do
        let!(:followup) { create(:followup, case_contact: contact) }

        it "advances the followup to the :resolved status" do
          sign_in admin

          post case_contact_followups_path(contact)
          expect(followup.reload.status).to eq("resolved")
        end
      end
    end

    context "with invalid case_contact" do
      it "raises ActiveRecord::RecordNotFound" do
        sign_in admin

        expect {
          post case_contact_followups_path(444444)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end

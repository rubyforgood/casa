require "rails_helper"

RSpec.describe CasaCasesController, type: :controller do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin) }
  let!(:casa_case) { create(:casa_case, casa_org: organization) }

  context "when logged in as an admin user" do
    before do
      sign_in admin
    end

    describe "#deactivate" do
      context "when request formate is json" do
        it "should deactivate the casa_case when provided valid case_id" do
          patch :deactivate, format: :json, params: {
            id: casa_case.id
          }

          expect(response.status).to eq 200
          expect(response.body).to eq "Case #{casa_case.case_number} has been deactivated."
        end

        it "should return 404 error when provided invalid case_id" do
          patch :deactivate, format: :json, params: {
            id: 123
          }
          expect(response.status).to eq 404
        end
      end

      context "when request formate is html" do
        it "should deactivate the casa_case when provided valid case_id" do
          patch :deactivate, params: {
            id: casa_case.id
          }

          expect(response.status).to eq 302
          expect(response).to redirect_to(edit_casa_case_path(casa_case))
          expect(flash[:notice]).to eq "Case #{casa_case.case_number} has been deactivated."
        end
      end
    end

    describe "#reactivate" do
      context "when request formate is json" do
        it "should reactivate the casa_case when provided valid case_id" do
          patch :reactivate, format: :json, params: {
            id: casa_case.id
          }

          expect(response.status).to eq 200
          expect(response.body).to eq "Case #{casa_case.case_number} has been reactivated."
        end

        it "should return 404 error when provided invalid case_id" do
          patch :reactivate, format: :json, params: {
            id: 123
          }
          expect(response.status).to eq 404
        end
      end

      context "when request formate is html" do
        it "should reactivate the casa_case when provided valid case_id" do
          patch :reactivate, params: {
            id: casa_case.id
          }

          expect(response.status).to eq 302
          expect(response).to redirect_to(edit_casa_case_path(casa_case))
          expect(flash[:notice]).to eq "Case #{casa_case.case_number} has been reactivated."
        end
      end
    end
  end
end

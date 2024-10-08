require "rails_helper"

RSpec.describe EmancipationsController, type: :controller do
  let(:organization) { build(:casa_org) }
  let(:volunteer) { create(:volunteer, :with_casa_cases, casa_org: organization) }
  let(:test_case_category) { build(:casa_case_emancipation_category) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }
  let(:casa_case_id) { casa_case.id.to_s }
  let(:params) do
    {
      casa_case_id: casa_case_id
    }
  end

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(volunteer)
  end

  describe "show" do
    context "json request" do
      subject(:show) { get :show, params: {casa_case_id: casa_case_id, format: :json} }

      context "not_authorized" do
        before do
          allow_any_instance_of(Volunteer).to receive(:casa_org).and_return nil
        end

        it "responds unauthorized" do
          show
          expect(response).to have_http_status(:unauthorized)
        end

        context "the backtrace ends in 'save'" do
          before do
            allow_any_instance_of(Organizational::UnknownOrganization).to receive(:backtrace).and_return(["", "", "save'"])
          end

          it "will render the correct json message" do
            show
            expect(response).to have_http_status(:unauthorized)
            expect(response.body).to eq({error: "Sorry, you are not authorized to perform this action. Did the session expire?"}.to_json)
          end
        end
      end
    end
  end
end

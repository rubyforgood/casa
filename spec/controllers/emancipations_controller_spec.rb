require "rails_helper"

RSpec.describe EmancipationsController, type: :controller do
  let(:organization) { create(:casa_org) }
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
    sign_in volunteer
  end

  describe "show" do
    context "json request" do
      subject(:show) { get :show, params: {casa_case_id: casa_case_id, format: :json} }

      context "not_authorized" do
        before do
          allow(controller).to receive(:current_organization).and_return(build_stubbed(:casa_org))
        end

        it "responds unauthorized" do
          show
          expect(response).to have_http_status(:unauthorized)
        end

        it "renders the correct json message" do
          show
          expect(response).to have_http_status(:unauthorized)
          expect(response.body).to eq({error: "Sorry, you are not authorized to perform this action."}.to_json)
        end
      end
    end
  end
end

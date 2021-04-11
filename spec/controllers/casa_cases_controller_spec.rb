require "rails_helper"

RSpec.describe CasaCasesController, type: :controller do
  let(:organization) { create(:casa_org) }
  let(:volunteer) { create(:volunteer, :with_cases_and_contacts, casa_org: organization) }

  describe "#show" do
    context "when logged in as volunteer" do
      before do
        allow(controller).to receive(:authenticate_user!).and_return(true)
        allow(controller).to receive(:current_user).and_return(volunteer)
      end

      it "should export csv successfully" do
        case_id = volunteer.casa_cases.first.id

        get :show, params: {id: case_id, format: :csv}
        expect(response).to have_http_status(:ok)
        # TODO: add more test cases to cover the amount of data that's exported
      end
    end
  end
end

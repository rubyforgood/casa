require "rails_helper"

RSpec.describe ReimbursementsController, type: :controller do
  let(:admin) { create(:casa_admin) }

  before do
    allow(controller).to receive(:authenticate_user!).and_return(:admin)
  end

  describe "as admin" do
    before do
      allow(controller).to receive(:current_user).and_return(admin)
    end

    it "can see reimbursements page" do
      get :index
      expect(response).to render_template("index")
    end
  end
end

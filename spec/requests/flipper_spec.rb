require "rails_helper"

RSpec.describe "Flipper" do
  let(:user) { create(:all_casa_admin) }

  before { sign_in user }

  describe "GET /flipper" do
    it "redirects to flipper ui" do
      get "/flipper"
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to("/flipper/features")
    end

    context "when user is not an all casa admin" do
      let(:user) { create(:casa_admin) }

      it "redirects to root" do
        get "/flipper"
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end

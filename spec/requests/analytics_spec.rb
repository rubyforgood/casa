require "rails_helper"

RSpec.describe "Analytics", type: :request do
  let(:organization) { create(:casa_org) }

  describe "GET /analytics" do
    context "as a casa_admin" do
      before { sign_in create(:casa_admin, casa_org: organization) }

      it "renders the chapter analytics dashboard" do
        get analytics_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Case contacts logged")
        expect(response.body).to include("When contacts are logged")
        expect(response.body).to include("Monthly active users")
      end

      it "accepts a range preset" do
        get analytics_path(range: 3)
        expect(response.body).to include("Last 3 months")
      end
    end

    context "as a supervisor" do
      before { sign_in create(:supervisor, casa_org: organization) }

      it "is allowed" do
        get analytics_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "as a volunteer" do
      before { sign_in create(:volunteer, casa_org: organization) }

      it "is not authorized" do
        get analytics_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "when signed out" do
      it "redirects to the sign-in page" do
        get analytics_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end

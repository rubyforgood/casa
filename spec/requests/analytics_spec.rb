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

      it "shows the chapter KPI cards" do
        get analytics_path
        expect(response.body).to include("Contacts this month")
        expect(response.body).to include("Active volunteers")
        expect(response.body).to include("Cases needing contact")
      end

      it "computes the month-over-month contact delta" do
        kase = create(:casa_case, casa_org: organization)
        2.times { create(:case_contact, :active, casa_case: kase, created_at: Time.current.beginning_of_month + 1.day) }
        create(:case_contact, :active, casa_case: kase, created_at: 1.month.ago.beginning_of_month + 1.day)

        get analytics_path
        expect(response.body).to include("+1 vs last month")
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

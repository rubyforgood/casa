require "rails_helper"

RSpec.describe "AllCasaAdmins::Metrics", type: :request do
  describe "GET /all_casa_admins/metrics" do
    context "when signed in as an all-CASA admin" do
      let(:all_casa_admin) { create(:all_casa_admin) }

      before { sign_in all_casa_admin }

      it "renders the platform metrics dashboard" do
        get all_casa_admins_metrics_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Case contacts logged")
        expect(response.body).to include("When contacts are logged")
        expect(response.body).to include("Monthly active users")
      end

      it "defaults to the 12-month range and accepts a preset" do
        get all_casa_admins_metrics_path
        expect(response.body).to include("Last 12 months")
        expect(response.body).to include(%(aria-current="page"))

        get all_casa_admins_metrics_path(range: 3)
        expect(response.body).to include("Last 3 months")
      end

      it "ignores an out-of-range value" do
        get all_casa_admins_metrics_path(range: 999)
        expect(response).to have_http_status(:ok)
      end

      it "aggregates case contacts across every chapter" do
        org_a = create(:casa_org)
        org_b = create(:casa_org)
        create(:case_contact, :active, casa_case: create(:casa_case, casa_org: org_a), created_at: Time.current, notes: "a")
        create(:case_contact, :active, casa_case: create(:casa_case, casa_org: org_b), created_at: Time.current, notes: "b")

        get all_casa_admins_metrics_path(range: 3)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Total contacts")
      end
    end

    context "when not signed in as an all-CASA admin" do
      it "redirects to the all-CASA sign-in" do
        get all_casa_admins_metrics_path
        expect(response).to redirect_to(new_all_casa_admin_session_path)
      end
    end
  end
end

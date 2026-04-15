require "rails_helper"

RSpec.describe "MileageReports", type: :request do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:volunteer) { create(:volunteer, casa_org: organization) }

  describe "GET /index" do
    context "as an admin" do
      before { sign_in admin }

      it "returns a CSV response" do
        get mileage_reports_path(format: :csv)

        expect(response).to have_http_status(:success)
        expect(response.content_type).to include("text/csv")
      end

      it "includes a filename with today's date" do
        get mileage_reports_path(format: :csv)

        expected_date = Time.current.strftime("%Y-%m-%d")
        expect(response.headers["Content-Disposition"]).to include("mileage-report-#{expected_date}.csv")
      end
    end

    context "as a supervisor" do
      let(:supervisor) { create(:supervisor, casa_org: organization) }

      before { sign_in supervisor }

      it "returns a CSV response" do
        get mileage_reports_path(format: :csv)
        expect(response).to have_http_status(:success)
      end
    end

    context "as a volunteer" do
      before { sign_in volunteer }

      it "redirects to root as not authorized" do
        get mileage_reports_path(format: :csv)

        expect(response).to redirect_to(root_url)
        expect(flash[:notice]).to eq("Sorry, you are not authorized to perform this action.")
      end
    end
  end
end

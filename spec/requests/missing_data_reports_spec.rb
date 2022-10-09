require "rails_helper"

RSpec.describe MissingDataReportsController, type: :request do
  let(:admin) { create(:casa_admin) }

  context "as an admin user" do
    describe "GET /index" do
      before do
        sign_in admin
        get missing_data_reports_path(format: :csv)
      end

      it "returns a successful response" do
        expect(response).to be_successful
        expect(response.header["Content-Type"]).to eq("text/csv")
      end
    end
  end

  context "without authenctication" do
    describe "GET /index" do
      before { get missing_data_reports_path(format: :csv) }

      it "return unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end

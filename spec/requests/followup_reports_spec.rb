# frozen_string_literal: true

require "rails_helper"

RSpec.describe "FollowupReports", type: :request do
  describe "GET /index" do
    context "when the user has access" do
      let(:admin) { build(:casa_admin) }

      it "returns the CSV report" do
        sign_in admin

        get followup_reports_path(format: :csv)

        expect(response).to have_http_status(:success)
        expect(response.header["Content-Type"]).to eq("text/csv")
        expect(response.headers["Content-Disposition"]).to(
          match("followup-report-#{Time.current.strftime("%Y-%m-%d")}.csv")
        )
      end

      it "adds the correct headers to the csv" do
        sign_in admin

        get followup_reports_path(format: :csv)

        csv_headers = [
          "Case Number",
          "Volunteer Name(s)",
          "Note Creator Name",
          "Note"
        ]

        csv_headers.each { |header| expect(response.body).to include(header) }
      end
    end

    context "when the user is not authorized to access" do
      it "redirects to root and displays an unauthorized message" do
        volunteer = build(:volunteer)
        sign_in volunteer

        get followup_reports_path(format: :csv)

        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end
  end
end

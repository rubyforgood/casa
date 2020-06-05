require "rails_helper"

RSpec.describe "/case_contact_reports", type: :request do
  describe "GET /case_contact_reports with start_date and end_date" do
    it "renders a csv file to download" do
      sign_in create(:user, :volunteer)
      create(:case_contact)

      get case_contact_reports_url(format: :csv), params: case_contact_report_params

      expect(response).to be_successful
      expect(
        response.headers["Content-Disposition"]
      ).to include 'attachment; filename="case-contacts-report-'
    end
  end

  describe "GET /case_contact_reports without start_date and end_date" do
    it "renders a csv file to download" do
      sign_in create(:user, :volunteer)
      create(:case_contact)

      get case_contact_reports_url(format: :csv)

      expect(response).to be_successful
      expect(
        response.headers["Content-Disposition"]
      ).to include 'attachment; filename="case-contacts-report-'
    end
  end

  def case_contact_report_params
    {
      start_date: 1.month.ago,
      end_date: Date.today
    }
  end
end

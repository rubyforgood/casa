require "rails_helper"

RSpec.describe "/case_contact_reports", type: :request do
  let(:volunteer) { create(:volunteer) }
  let!(:case_contact) { create(:case_contact) }

  before do
    travel_to Time.local(2020,1,1)
    sign_in volunteer
  end
  after { travel_back }

  describe "GET /case_contact_reports with start_date and end_date" do
    let(:case_contact_report_params) {
      {
        start_date: 1.month.ago,
        end_date: Date.today
      }
    }

    it "renders a csv file to download" do
      get case_contact_reports_url(format: :csv), params: case_contact_report_params

      expect(response).to be_successful
      expect(
        response.headers["Content-Disposition"]
      ).to include 'attachment; filename="case-contacts-report-1577836800.csv'
    end
  end

  describe "GET /case_contact_reports without start_date and end_date" do
    it "renders a csv file to download" do
      get case_contact_reports_url(format: :csv)

      expect(response).to be_successful
      expect(
        response.headers["Content-Disposition"]
      ).to include 'attachment; filename="case-contacts-report-1577836800.csv'
    end
  end
end

require "rails_helper"

RSpec.describe "LearningHoursReports", type: :request do
  let(:organization) { create(:casa_org) }
  let(:admin) { build(:casa_admin, casa_org: organization) }

  describe "GET /index" do
    subject(:request) do
      get "#{learning_hours_reports_url}.csv"

      response
    end

    before do
      sign_in admin
      allow(LearningHoursReport).to receive(:new).and_call_original
    end

    it { is_expected.to be_successful }

    it "triggers report generation correctly" do
      request
      expect(LearningHoursReport).to have_received(:new).once.with(organization.id)
    end

    it "sends downloadable data correctly", :aggregate_failures do
      response_headers = request.headers

      expect(response_headers["Content-Type"]).to match("text/csv")
      expect(response_headers["Content-Disposition"]).to(
        match("learning-hours-report-#{Time.current.strftime("%Y-%m-%d")}.csv")
      )
    end
  end
end

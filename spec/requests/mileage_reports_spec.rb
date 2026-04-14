require "rails_helper"

RSpec.describe "/mileage_reports", type: :request do
  before do
    travel_to Time.zone.local(2025, 4, 14)
    sign_in user
  end

  describe "GET /mileage_reports" do
    context "as casa_admin" do
      let(:user) { create(:casa_admin) }

      it "renders a csv file to download" do
        get mileage_reports_url(format: :csv)

        expect(response).to be_successful
        expect(
          response.headers["Content-Disposition"]
        ).to include 'attachment; filename="mileage-report-2025-04-14.csv'
      end

      it "includes case contact mileage data in csv" do
        volunteer = create(:volunteer, casa_org: user.casa_org)
        casa_case = create(:casa_case, casa_org: user.casa_org)
        create(:case_assignment, volunteer: volunteer, casa_case: casa_case)
        create(:case_contact,
          creator: volunteer,
          casa_case: casa_case,
          want_driving_reimbursement: true,
          miles_driven: 25)

        get mileage_reports_url(format: :csv)

        expect(response).to be_successful
        expect(response.body).to include("25")
      end
    end

    context "as supervisor" do
      let(:user) { create(:supervisor) }

      it "renders a csv file to download" do
        get mileage_reports_url(format: :csv)

        expect(response).to be_successful
        expect(
          response.headers["Content-Disposition"]
        ).to include 'attachment; filename="mileage-report-2025-04-14.csv'
      end
    end

    context "as volunteer" do
      let(:user) { create(:volunteer) }

      it "cannot view reports" do
        get mileage_reports_url(format: :csv)

        expect(response).to redirect_to root_path
      end
    end

    context "when not signed in" do
      let(:user) { create(:volunteer) }

      it "redirects to sign in" do
        sign_out user
        get mileage_reports_url(format: :csv)

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end

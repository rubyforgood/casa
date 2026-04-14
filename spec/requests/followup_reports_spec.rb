require "rails_helper"

RSpec.describe "/followup_reports", type: :request do
  before do
    travel_to Time.zone.local(2025, 4, 14)
    sign_in user
  end

  describe "GET /followup_reports" do
    context "as casa_admin" do
      let(:user) { create(:casa_admin) }

      it "renders a csv file to download" do
        get followup_reports_url(format: :csv)

        expect(response).to be_successful
        expect(
          response.headers["Content-Disposition"]
        ).to include 'attachment; filename="followup-report-2025-04-14.csv'
      end

      it "includes followup data in csv" do
        casa_case = create(:casa_case, casa_org: user.casa_org)
        case_contact = create(:case_contact, casa_case: casa_case)
        create(:followup, case_contact: case_contact)

        get followup_reports_url(format: :csv)

        expect(response).to be_successful
        expect(response.body).to include(casa_case.case_number)
      end
    end

    context "as supervisor" do
      let(:user) { create(:supervisor) }

      it "renders a csv file to download" do
        get followup_reports_url(format: :csv)

        expect(response).to be_successful
        expect(
          response.headers["Content-Disposition"]
        ).to include 'attachment; filename="followup-report-2025-04-14.csv'
      end
    end

    context "as volunteer" do
      let(:user) { create(:volunteer) }

      it "cannot view reports" do
        get followup_reports_url(format: :csv)

        expect(response).to redirect_to root_path
      end
    end

    context "when not signed in" do
      let(:user) { create(:volunteer) }

      it "redirects to sign in" do
        sign_out user
        get followup_reports_url(format: :csv)

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end

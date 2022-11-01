require "rails_helper"

RSpec.describe "/reports", type: :request do
  describe "GET #index" do
    subject do
      get reports_url
      response
    end

    context "while signed in as an admin" do
      before do
        sign_in build(:casa_admin)
      end

      it { is_expected.to be_successful }
    end

    context "while signed in as a supervisor" do
      before do
        sign_in build(:supervisor)
      end

      it { is_expected.to be_successful }
    end

    context "while signed in as a volunteer" do
      before do
        sign_in build(:volunteer)
      end

      it { is_expected.not_to be_successful }
    end
  end

  describe "GET #export_emails" do
    before do
      sign_in build(:casa_admin)
    end

    it "renders a csv file to download" do
      get export_emails_url(format: :csv)

      expect(response).to be_successful
      expect(
        response.headers["Content-Disposition"]
      ).to include "attachment; filename=\"volunteers-emails-#{Time.current.strftime("%Y-%m-%d")}.csv"
    end
  end
end

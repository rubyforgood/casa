require "rails_helper"

RSpec.describe "Banners", type: :request do
  let!(:casa_org) { create(:casa_org) }
  let!(:active_banner) { create(:banner, casa_org: casa_org) }
  let(:volunteer) { create(:volunteer, casa_org: casa_org) }

  context "when user dismisses a banner" do
    subject do
      get dismiss_banner_path(active_banner)
    end

    it "sets session variable" do
      sign_in volunteer
      subject
      expect(session[:dismissed_banner]).to eq active_banner.id
    end

    it "does not display banner on page reloads" do
      sign_in volunteer
      get casa_cases_path
      expect(response.body).to include "Please fill out this survey"

      subject
      get casa_cases_path
      expect(response.body).not_to include "Please fill out this survey"
    end

    context "when user logs out and back in" do
      it "nils out session variable" do
        sign_in volunteer
        subject
        get destroy_user_session_path
        sign_in volunteer

        expect(session[:dismissed_banner]).to be_nil
      end

      it "displays banner" do
        sign_in volunteer
        subject
        get destroy_user_session_path
        sign_in volunteer

        get casa_cases_path
        expect(response.body).to include "Please fill out this survey"
      end
    end
  end
end

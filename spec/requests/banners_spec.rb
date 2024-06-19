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

  context "when a banner has expires_at" do
    context "when expires_at is after today" do
      let!(:active_banner) { create(:banner, casa_org: casa_org, expires_at: 7.days.from_now) }

      it "displays the banner" do
        sign_in volunteer
        get casa_cases_path
        expect(response.body).to include "Please fill out this survey"
      end
    end

    context "when expires_at is before today" do
      let!(:active_banner) do
        banner = create(:banner, casa_org: casa_org, expires_at: nil)
        banner.update_columns(expires_at: 1.day.ago)
      end

      it "does not display the banner" do
        sign_in volunteer
        get casa_cases_path
        expect(response.body).not_to include "Please fill out this survey"
      end
    end
  end

  context "when creating a banner" do
    let(:admin) { create(:casa_admin, casa_org: casa_org) }
    let(:banner_params) do
      {
        user: admin,
        active: false,
        content: "Test",
        name: "Test Announcement",
        expires_at: expires_at
      }
    end

    context "when client timezone is ahead of UTC" do
      context "when submitted time is behind client but ahead of UTC" do
        let(:expires_at) { Time.new(2024, 6, 1, 9, 0, 0, "UTC") } # 12:00 +03:00

        it "succeeds" do
          travel_to Time.new(2024, 6, 1, 11, 0, 0, "+03:00") do # 08:00 UTC
            sign_in admin
            post banners_path, params: {banner: banner_params}
            expect(response).to redirect_to banners_path
          end
        end
      end

      context "when submitted time is behind client and behind UTC" do
        let(:expires_at) { Time.new(2024, 6, 1, 7, 0, 0, "UTC") } # 10:00 +03:00

        it "fails" do
          travel_to Time.new(2024, 6, 1, 11, 0, 0, "+03:00") do # 08:00 UTC
            sign_in admin
            post banners_path, params: {banner: banner_params}
            expect(response).to render_template "banners/new"
            expect(response.body).to include "Expires at must take place in the future (after 2024-06-01 08:00:00 UTC)"
          end
        end
      end
    end

    context "when client timezone is behind UTC" do
      context "when submitted time is ahead of client and ahead of UTC" do
        let(:expires_at) { Time.new(2024, 6, 1, 16, 0, 0, "UTC") } # 12:00 -04:00

        it "succeeds" do
          travel_to Time.new(2024, 6, 1, 11, 0, 0, "-04:00") do # 15:00 UTC
            sign_in admin
            post banners_path, params: {banner: banner_params}
            expect(response).to redirect_to banners_path
          end
        end
      end
    end

    context "when submitted time is ahead of client but behind UTC" do
      let(:expires_at) { Time.new(2024, 6, 1, 14, 0, 0, "UTC") } # 10:00 -04:00

      it "fails" do
        travel_to Time.new(2024, 6, 1, 11, 0, 0, "-04:00") do # 15:00 UTC
          sign_in admin
          post banners_path, params: {banner: banner_params}
          expect(response).to render_template "banners/new"
          expect(response.body).to include "Expires at must take place in the future (after 2024-06-01 15:00:00 UTC)"
        end
      end
    end
  end
end

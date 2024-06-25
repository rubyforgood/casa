require "rails_helper"

RSpec.describe "banners/new", type: :view do
  context "when new banner is marked as inactive" do
    it "does not warn that current active banner will be deactivated" do
      user = build_stubbed(:casa_admin)
      current_organization = user.casa_org
      current_organization_banner = build(:banner, active: true, casa_org: current_organization)

      allow(view).to receive(:current_user).and_return(user)
      allow(view).to receive(:current_organization).and_return(current_organization)
      without_partial_double_verification do
        allow(view).to receive(:browser_time_zone).and_return("America/New_York")
      end
      allow(current_organization).to receive(:has_alternate_active_banner?).and_return(true)

      assign :banners, [current_organization_banner]
      assign :banner, Banner.new(active: false)

      render template: "banners/new"

      expect(rendered).not_to have_checked_field("banner_active")
      expect(rendered).to have_css("span.d-none", text: "Warning: This will replace your current active banner")
    end
  end

  context "when organization has an active banner" do
    context "when new banner is marked as active" do
      it "warns that current active banner will be deactivated" do
        user = build_stubbed(:casa_admin)
        current_organization = user.casa_org
        current_organization_banner = build(:banner, active: true, casa_org: current_organization)

        allow(view).to receive(:current_user).and_return(user)
        allow(view).to receive(:current_organization).and_return(current_organization)
        without_partial_double_verification do
          allow(view).to receive(:browser_time_zone).and_return("America/New_York")
        end
        allow(current_organization).to receive(:has_alternate_active_banner?).and_return(true)

        assign :banners, [current_organization_banner]
        assign :banner, Banner.new(active: true)

        render template: "banners/new"

        expect(rendered).to have_checked_field("banner_active")
        expect(rendered).not_to have_css("span.d-none", text: "Warning: This will replace your current active banner")
      end
    end
  end

  context "when organization has no active banner" do
    context "when new banner is marked as active" do
      it "does not warn that current active banner will be deactivated" do
        user = build_stubbed(:casa_admin)
        current_organization = user.casa_org

        allow(view).to receive(:current_user).and_return(user)
        allow(view).to receive(:current_organization).and_return(current_organization)
        without_partial_double_verification do
          allow(view).to receive(:browser_time_zone).and_return("America/New_York")
        end
        allow(current_organization).to receive(:has_alternate_active_banner?).and_return(false)

        assign :banners, []
        assign :banner, Banner.new(active: true)

        render template: "banners/new"

        expect(rendered).to have_checked_field("banner_active")
        expect(rendered).to have_css("span.d-none", text: "Warning: This will replace your current active banner")
      end
    end
  end
end

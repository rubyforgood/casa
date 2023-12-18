require "rails_helper"

RSpec.describe BannerHelper do
  describe "#conditionally_add_hidden_class" do
    it "returns d-none if current banner is inactive" do
      current_organization = double
      allow(helper).to receive(:current_organization).and_return(current_organization)
      banner = double(id: 1)
      assign(:banner, banner)

      allow(current_organization).to receive(:has_alternate_active_banner?).and_return(true)

      expect(helper.conditionally_add_hidden_class(false)).to eq("d-none")
    end

    it "returns d-none if current banner is active and org does not have an alternate active banner" do
      current_organization = double
      allow(helper).to receive(:current_organization).and_return(current_organization)
      banner = double(id: 1)
      assign(:banner, banner)

      allow(current_organization).to receive(:has_alternate_active_banner?).and_return(false)

      expect(helper.conditionally_add_hidden_class(true)).to eq("d-none")
    end

    it "returns nil if current banner is active and org has an alternate active banner" do
      current_organization = double
      allow(helper).to receive(:current_organization).and_return(current_organization)
      banner = double(id: 1)
      assign(:banner, banner)

      allow(current_organization).to receive(:has_alternate_active_banner?).and_return(true)

      expect(helper.conditionally_add_hidden_class(true)).to eq(nil)
    end
  end

  describe "#active_banner" do
    let(:current_organization) { double }
    let(:banner) { double(id: 1) }

    before do
      allow(helper).to receive(:current_organization).and_return(current_organization)
      allow(current_organization).to receive(:banners).and_return(OpenStruct.new(active: []))
    end

    it "returns active banner if there is one" do
      allow(current_organization.banners).to receive(:active).and_return([banner])

      expect(helper.active_banner).to eq(banner)
    end

    it "returns nil if there is not active banners" do
      allow(current_organization.banners).to receive(:active).and_return([])

      expect(helper.active_banner).to eq(nil)
    end
  end

  describe "#active_banner?" do
    it "returns true if there is active banner" do
      allow(helper).to receive(:active_banner).and_return("foo")
      expect(helper.active_banner?).to eq(true)
    end

    it "returns false if there is no active banner" do
      allow(helper).to receive(:active_banner).and_return(nil)
      expect(helper.active_banner?).to eq(false)
    end
  end

  describe "#display_active_banner?" do
    it "returns true if banner message should be displayed" do
      cookies = double

      allow(helper).to receive(:active_banner?).and_return(true)
      allow(helper).to receive(:dismiss_banner_cookie_name).and_return("dismiss_banner_1")
      allow(cookies).to receive(:[]).with("dismiss_banner_1").and_return(nil)
      allow(helper).to receive(:cookies).and_return(cookies)

      expect(helper.display_active_banner?).to eq(true)
    end

    it "returns false if there is no active banner" do
      allow(helper).to receive(:active_banner?).and_return(false)

      expect(helper.display_active_banner?).to eq(false)
    end

    it "returns false if there active banner but no cookie set" do
      allow(helper).to receive(:active_banner?).and_return(true)
      allow(helper).to receive(:dismiss_banner_cookie_name).and_return("dismiss_banner_1")
      allow(cookies).to receive(:[]).with("dismiss_banner_1").and_return("true")
      allow(helper).to receive(:cookies).and_return(cookies)

      expect(helper.display_active_banner?).to eq(false)
    end
  end

  describe "#banner_cookie_name" do
    it "returns cookie name for the banner" do
      banner = double(id: 1)
      allow(helper).to receive(:active_banner).and_return(banner)
      expect(helper.banner_cookie_name).to eq("banner_1")
    end

    it "raises a StandardError if there is no active banner" do
      allow(helper).to receive(:active_banner?).and_return(false)

      expect {
        helper.banner_cookie_name
      }.to raise_error(StandardError, "No active banner")
    end
  end

  describe "#dismiss_banner_cookie_name" do
    it "returns the value of the dismiss banner cookie" do
      allow(helper).to receive(:banner_cookie_name).and_return("banner_1")
      expect(helper.dismiss_banner_cookie_name).to eq("dismiss_banner_1")
    end

    it "raises an error if there is no active banner" do
      allow(helper).to receive(:banner_cookie_name).and_raise(StandardError, "No active banner")

      expect {
        helper.dismiss_banner_cookie_name
      }.to raise_error(StandardError, "No active banner")
    end
  end
end

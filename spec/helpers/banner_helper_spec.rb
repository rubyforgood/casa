require "rails_helper"

RSpec.describe BannerHelper do
  describe "#conditionally_add_hidden_class" do
    it "returns d-none if current banner is inactive" do
      assign :org_has_alternate_active_banner, true

      expect(helper.conditionally_add_hidden_class(false)).to eq("d-none")
    end

    it "returns d-none if current banner is active and org does not have an alternate active banner" do
      assign :org_has_alternate_active_banner, false

      expect(helper.conditionally_add_hidden_class(true)).to eq("d-none")
    end

    it "returns nil if current banner is active and org has an alternate active banner" do
      assign :org_has_alternate_active_banner, true

      expect(helper.conditionally_add_hidden_class(true)).to eq(nil)
    end
  end
end

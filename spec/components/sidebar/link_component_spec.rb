# frozen_string_literal: true

require "rails_helper"

RSpec.describe Sidebar::LinkComponent, type: :component do
  context "component render" do
    it "is by default" do
      render_inline(described_class.new(title: "Supervisors", path: "/supervisors", icon: "network"))

      expect(page).to have_css "span[data-sidebar-target='linkTitle']", text: "Supervisors"
      expect(page).to have_css "a[href='/supervisors']"
      expect(page).to have_css "i[class='lni mr-10 lni-network']"
    end

    it "doesn't happen if render_check is false" do
      render_inline(described_class.new(title: "Supervisors", path: "/supervisors", icon: "network", render_check: false))

      expect(page).not_to have_css "span[data-sidebar-target='linkTitle']", text: "Supervisors"
    end
  end

  context "icon render" do
    it "doesn't happen if icon not set" do
      render_inline(described_class.new(title: "Supervisors", path: "/supervisors"))

      expect(page).not_to have_css "i"
    end
  end

  context "active class" do
    it "is rendered if request path matches link's path" do
      with_request_url "/supervisors" do
        render_inline(described_class.new(title: "Supervisors", path: "/supervisors", icon: "network"))

        expect(page).to have_css "li[class='nav-item active']"
      end
    end

    it "is not rendered if request path doesn't match" do
      with_request_url "/volunteers" do
        render_inline(described_class.new(title: "Supervisors", path: "/supervisors", icon: "network"))

        expect(page).to have_css "li[class='nav-item ']"
        expect(page).to have_no_content "li[class='nav-item active']"
      end
    end
  end
end

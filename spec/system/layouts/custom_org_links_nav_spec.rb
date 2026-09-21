require "rails_helper"

RSpec.describe "casa_app shell custom org links", type: :system do
  let(:casa_org) { create(:casa_org) }
  let!(:active_link) { create(:custom_org_link, casa_org: casa_org, text: "Volunteer handbook", url: "https://example.com/handbook") }
  let!(:inactive_link) { create(:custom_org_link, casa_org: casa_org, text: "Retired resource", url: "https://example.com/retired", active: false) }
  let!(:other_org_link) { create(:custom_org_link, text: "Another chapter resource", url: "https://example.com/elsewhere") }

  shared_examples "renders the organization's active custom links" do
    before do
      sign_in user
      visit casa_cases_path
    end

    it "lists the active links in the main navigation" do
      within "nav[aria-label='Main navigation']" do
        expect(page).to have_link(active_link.text, href: active_link.url)
      end
    end

    it "opens them in a new tab" do
      expect(page).to have_css("nav[aria-label='Main navigation'] a[href='#{active_link.url}'][target='_blank'][rel~='noopener']")
    end

    it "does not list inactive links" do
      expect(page).to have_no_link(inactive_link.text, href: inactive_link.url)
    end

    it "does not list links belonging to another organization" do
      expect(page).to have_no_link(other_org_link.text, href: other_org_link.url)
    end
  end

  context "as a volunteer" do
    let(:user) { create(:volunteer, casa_org: casa_org) }

    it_behaves_like "renders the organization's active custom links"
  end

  context "as a supervisor" do
    let(:user) { create(:supervisor, casa_org: casa_org) }

    it_behaves_like "renders the organization's active custom links"
  end

  context "as a casa admin" do
    let(:user) { create(:casa_admin, casa_org: casa_org) }

    it_behaves_like "renders the organization's active custom links"
  end

  context "when the organization has no active custom links" do
    it "renders no custom links group" do
      sign_in create(:casa_admin, casa_org: create(:casa_org))
      visit casa_cases_path

      expect(page).to have_no_css("nav[aria-label='Main navigation'] [aria-label='Links']")
    end
  end
end

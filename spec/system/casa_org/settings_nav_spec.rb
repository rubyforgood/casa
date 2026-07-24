require "rails_helper"

RSpec.describe "casa_org/edit settings navigation", :js, type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }

  before { sign_in admin }

  it "shows the first section by default and switches sections from the sub-nav" do
    visit edit_casa_org_path(organization)

    expect(page).to have_css("#organization-details-body", visible: :visible)
    expect(page).to have_css("#hearing-types-body", visible: :hidden)

    click_link "Hearing types"

    expect(page).to have_css("#hearing-types-body", visible: :visible)
    expect(page).to have_css("#organization-details-body", visible: :hidden)
  end

  it "opens the section named in the URL (deep link from the case-contact form)" do
    visit edit_casa_org_path(organization, anchor: "case-contact-topics")

    expect(page).to have_css("#case-contact-topics-body", visible: :visible)
    expect(page).to have_css("#organization-details-body", visible: :hidden)
  end
end

require "rails_helper"

RSpec.describe "all_casa_admins/casa_orgs/new", type: :view do
  let(:organization) { create :casa_org }
  let(:admin) { build_stubbed(:all_casa_admin) }

  before do
    allow(view).to receive(:selected_organization).and_return(organization)
    sign_in admin

    render template: "all_casa_admins/casa_orgs/new"
  end

  it "shows new CASA Organization page title" do
    expect(rendered).to have_text("Create a new CASA Organization")
  end

  it "shows new CASA Organization form" do
    expect(rendered).to have_selector("input", id: "casa_org_name")
    expect(rendered).to have_selector("input", id: "casa_org_display_name")
    expect(rendered).to have_selector("input", id: "casa_org_address")
    expect(rendered).to have_selector("button", id: "submit")
  end

  it "requires name text field" do
    expect(rendered).to have_selector("input[required=required]", id: "casa_org_name")
  end
end

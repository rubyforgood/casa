require "rails_helper"

RSpec.describe "admin or supervisor see link to own edit page after create case contact", type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:supervisor) { create(:supervisor, casa_org: organization) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }

  it "admin see link to index admin page" do
    sign_in admin
    create(:case_contact, creator: admin, casa_case_id: casa_case.id)
    visit casa_case_path(casa_case.id)

    expect(page).to have_link(href: "/users/edit")
  end

  it "supervisor see link to own edit page" do
    sign_in supervisor
    create(:case_contact, creator: supervisor, casa_case_id: casa_case.id)
    visit casa_case_path(casa_case.id)

    expect(page).to have_link(href: "/supervisors/#{supervisor.id}/edit")
  end
end

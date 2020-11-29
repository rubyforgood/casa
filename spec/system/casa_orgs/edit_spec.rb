require "rails_helper"

RSpec.describe "casa_orgs/edit", type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org_id: organization.id) }
  let!(:hearing_type) { create(:hearing_type, casa_org: organization, name: "Spec Test Hearing Type") }
  let!(:judge) { create(:judge, casa_org: organization, name: "Joey Tom") }

  before do
    sign_in admin

    visit edit_casa_org_path(organization)
  end

  it "loads casa org edit page" do
    expect(page).to have_text "Editing CASA Organization"
    expect(page).to_not have_text "sign in before continuing"
  end

  it "has hearing types content" do
    expect(page).to have_text("Spec Test Hearing Type")
    expect(page).to have_text(hearing_type.name)
  end

  it "has hearing types table" do
    scroll_to(page.find("table#hearing-types", visible: false))
    expect(page).to have_table(
      id: "hearing-types",
      with_rows:
      [
        ["Spec Test Hearing Type", "Yes", "Edit"]
      ]
    )
  end

  it "has judge content" do
    expect(page).to have_text(judge.name)
  end
end

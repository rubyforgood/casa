require "rails_helper"

RSpec.describe "casa_orgs/edit", :disable_bullet, type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org_id: organization.id) }
  let!(:contact_type_group) { create(:contact_type_group, casa_org: organization, name: "Contact type group 1") }
  let!(:contact_type) { create(:contact_type, name: "Contact type 1") }
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

  it "has contact type groups content" do
    expect(page).to have_text("Contact type group 1")
    expect(page).to have_text(contact_type_group.name)
  end

  it "has contact type groups table", js: true do
    scroll_to(page.find("table#contact-type-groups", visible: false))
    expect(page).to have_table(
      id: "contact-type-groups",
      with_rows:
      [
        ["Contact type group 1", "Yes", "Edit"]
      ]
    )
  end

  it "has contact types content" do
    expect(page).to have_text("Contact type 1")
    expect(page).to have_text(contact_type.name)
  end

  it "has contact types table", js: true do
    scroll_to(page.find("table#contact-types", visible: false))
    expect(page).to have_table(
      id: "contact-types",
      with_rows:
      [
        ["Contact type 1", "Yes", "Edit"]
      ]
    )
  end

  it "has hearing types content" do
    expect(page).to have_text("Spec Test Hearing Type")
    expect(page).to have_text(hearing_type.name)
  end

  it "has hearing types table", js: true do
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

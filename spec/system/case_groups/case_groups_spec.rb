require "rails_helper"

RSpec.describe "Case Groups", type: :system, js: true do
  let(:admin) { create(:casa_admin) }
  let(:organization) { admin.casa_org }

  it "create a case group" do
    casa_case = create(:casa_case)

    sign_in admin

    visit case_groups_path
    click_on "New Case Group"
    fill_in "Name", with: "A family"
    find(".multiselect-dropdown").click
    find('input[type="checkbox"] + label', text: casa_case.case_number).sibling('input[type="checkbox"]').set(true)
    find("#case_group_name").click

    click_on "Submit"

    visit case_groups_path
    expect(page).to have_text("A family")

    within "#case-groups" do
      click_on "Edit", match: :first
    end
    fill_in "Name", with: "Another family"
    click_on "Submit"

    visit case_groups_path
    expect(page).to have_text("Another family")
  end
end

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
    select casa_case.case_number, from: "Cases"
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

  it "will not create a case group if the name is not unique" do
    casa_case = create(:casa_case)

    sign_in admin

    visit case_groups_path
    click_on "New Case Group"
    fill_in "Name", with: "A family"
    select casa_case.case_number, from: "Cases"
    click_on "Submit"

    visit case_groups_path
    click_on "New Case Group"
    fill_in "Name", with: "A Family "
    select casa_case.case_number, from: "Cases"
    click_on "Submit"

    expect(page).to have_text("Name has already been taken")

    visit case_groups_path
    expect(page).to have_text("A family").once
  end
end

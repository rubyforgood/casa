require "rails_helper"

RSpec.describe "Case Groups", type: :system, js: true do
  let(:admin) { create(:casa_admin) }
  let(:organization) { admin.casa_org }

  it "create a case group" do
    casa_case1 = create(:casa_case)
    casa_case2 = create(:casa_case)

    sign_in admin

    visit case_groups_path
    click_on "New Case Group"
    fill_in "Name", with: "A family"
    find(".ts-control > input").click
    find("div.option", text: casa_case1.case_number).click
    find("div.option", text: casa_case2.case_number).click
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

  it "remove from a case group" do
    casa_case1 = create(:casa_case)
    casa_case2 = create(:casa_case)

    sign_in admin

    visit case_groups_path
    click_on "New Case Group"
    fill_in "Name", with: "A family"
    find(".ts-control > input").click
    find("div.option", text: casa_case1.case_number).click
    find("div.option", text: casa_case2.case_number).click
    find("#case_group_name").click

    click_on "Submit"

    visit case_groups_path
    expect(page).to have_text(casa_case1.case_number)
    expect(page).to have_text(casa_case2.case_number)

    within "#case-groups" do
      click_on "Edit", match: :first
    end
    case2_selector = find(".ts-control > div.item", text: casa_case2.case_number)
    within case2_selector do
      find("a").click
    end
    click_on "Submit"

    visit case_groups_path
    expect(page).to have_text(casa_case1.case_number)
    expect(page).to_not have_text(casa_case2.case_number)
  end
end

require "rails_helper"

RSpec.describe "Case Groups", :js do
  let(:admin) { create(:casa_admin) }
  let(:casa_org) { admin.casa_org }

  it "create a case group" do
    casa_case1 = create(:casa_case, casa_org:)
    casa_case2 = create(:casa_case, casa_org:)

    sign_in admin

    visit case_groups_path
    click_on "New Case Group"
    fill_in "Name", with: "A family"
    find(".ts-control > input").click
    find("div.option", text: casa_case1.case_number).click
    find("div.option", text: casa_case2.case_number).click
    find_by_id("case_group_name").click

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
    casa_case1 = create(:casa_case, casa_org:)
    casa_case2 = create(:casa_case, casa_org:)

    sign_in admin

    visit case_groups_path
    click_on "New Case Group"
    fill_in "Name", with: "A family"
    find(".ts-control > input").click
    find("div.option", text: casa_case1.case_number).click
    find("div.option", text: casa_case2.case_number).click
    find_by_id("case_group_name").click

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
    expect(page).to have_no_text(casa_case2.case_number)
  end

  it "does not create a case group if the name is not unique" do
    casa_case = create(:casa_case, casa_org: admin.casa_org)

    sign_in admin

    visit case_groups_path
    click_on "New Case Group"
    fill_in "Name", with: "A family"
    find(".ts-control > input").click
    find("div.option", text: casa_case.case_number).click
    find_by_id("case_group_name").click
    click_on "Submit"

    visit case_groups_path
    click_on "New Case Group"
    fill_in "Name", with: "A Family "
    find(".ts-control > input").click
    find("div.option", text: casa_case.case_number).click
    find_by_id("case_group_name").click
    click_on "Submit"

    expect(page).to have_text("Name has already been taken")

    visit case_groups_path
    expect(page).to have_text("A family").once
  end
end

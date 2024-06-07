require "rails_helper"

RSpec.describe "Banners", type: :system, js: true do
  let(:admin) { create(:casa_admin) }
  let(:organization) { admin.casa_org }

  it "adds a banner" do
    sign_in admin

    visit banners_path
    click_on "New Banner"
    fill_in "Name", with: "Volunteer Survey Announcement"
    check "Active?"
    fill_in_rich_text_area "banner_content", with: "Please fill out this survey."
    click_on "Submit"

    visit banners_path
    expect(page).to have_text("Volunteer Survey Announcement")

    visit banners_path
    within "#banners" do
      click_on "Edit", match: :first
    end
    fill_in "Name", with: "Better Volunteer Survey Announcement"
    click_on "Submit"

    visit banners_path
    expect(page).to have_text("Better Volunteer Survey Announcement")

    visit root_path
    expect(page).to have_text("Please fill out this survey.")
  end

  it "lets you create banner with expiration time and edit it" do
    sign_in admin

    visit banners_path
    click_on "New Banner"
    fill_in "Name", with: "Expiring Announcement"
    check "Active?"
    fill_in "banner_expires_at", with: 7.days.from_now.strftime("%m%d%Y\t%I%M%P")
    fill_in_rich_text_area "banner_content", with: "Please fill out this survey."
    click_on "Submit"

    visit banners_path
    expect(page).to have_text("Expiring Announcement")

    visit banners_path
    within "#banners" do
      click_on "Edit", match: :first
    end
    fill_in "banner_expires_at", with: 2.days.from_now.strftime("%m%d%Y\t%I%M%P")
    click_on "Submit"

    visit banners_path
    expect(page).to have_text("Expiring Announcement")

    visit root_path
    expect(page).to have_text("Please fill out this survey.")
  end

  describe "when an organization has an active banner" do
    let(:admin) { create(:casa_admin) }
    let(:organization) { create(:casa_org) }
    let(:active_banner) { create(:banner, casa_org: organization) }

    context "when a banner is submitted as active" do
      it "deactivates and replaces the current active banner" do
        active_banner

        sign_in admin

        visit banners_path
        expect(page).to have_text(active_banner.content.body.to_plain_text)
        click_on "New Banner"
        fill_in "Name", with: "New active banner name"
        check "Active?"
        fill_in_rich_text_area "banner_content", with: "New active banner content."
        click_on "Submit"

        visit banners_path
        within("table#banners") do
          already_existing_banner_row = find("tr", text: active_banner.name)

          expect(already_existing_banner_row).to have_selector("td.min-width", text: "No")
        end

        expect(page).to have_text("New active banner content.")
      end
    end

    context "when a banner is submitted as inactive" do
      it "does not deactivate the current active banner" do
        active_banner

        sign_in admin

        visit banners_path
        expect(page).to have_text(active_banner.content.body.to_plain_text)
        click_on "New Banner"
        fill_in "Name", with: "New active banner name"
        fill_in_rich_text_area "banner_content", with: "New active banner content."
        click_on "Submit"

        visit banners_path

        within("table#banners") do
          already_existing_banner_row = find("tr", text: active_banner.name)

          expect(already_existing_banner_row).to have_selector("td.min-width", text: "Yes")
        end

        expect(page).to have_text(active_banner.content.body.to_plain_text)
      end
    end
  end
end

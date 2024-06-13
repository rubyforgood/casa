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

  it "does not allow creation of banner with an expiration time set in the past" do
    sign_in admin

    freeze_time do
      current_time = Time.current
      visit banners_path
      page.driver.browser.manage.add_cookie(name: "browser_time_zone", value: "America/Chicago")
      click_on "New Banner"
      fill_in "Name", with: "Announcement"
      fill_in "banner_expires_at", with: (current_time - 1.hour).strftime("%m%d%Y\t%I%M%P")
      fill_in_rich_text_area "banner_content", with: "Please fill out this survey."
      click_on "Submit"

      message = page.find("#banner_expires_at").native.attribute("validationMessage")
      expect(message).to eq("Value must be #{current_time.in_time_zone("America/Chicago").strftime("%m/%d/%Y, %I:%M %p or later.")}")
    end
  end

  it "does not allow creation of banner with an expiration time set in the past" do
    sign_in admin

    travel_to Time.zone.local(2000, 2, 2, 12, 0, 0) # 02/02/2000 at noon
    visit banners_path

    page.driver.browser.manage.add_cookie(name: "browser_time_zone", value: "UTC")
    click_on "New Banner"
    fill_in "Name", with: "Announcement"
    fill_in "banner_expires_at", with: "02022000\t1100am" # 02/02/2000 at 11AM
    fill_in_rich_text_area "banner_content", with: "Please fill out this survey."
    click_on "Submit"

    message = page.find("#banner_expires_at").native.attribute("validationMessage")
    # NOTE: the space before PM is special, you will need to copy an paste it
    expected = "Value must be 02/02/2000, 12:00 PM or later." 
    expect(message).to eq(expected)
    travel_back
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

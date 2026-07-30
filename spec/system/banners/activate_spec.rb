require "rails_helper"

RSpec.describe "banners/activate", :js, type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }

  it "tells you when a new banner is not showing, and lets you activate it from the list" do
    sign_in admin
    visit new_banner_path
    fill_in "Name", with: "Survey reminder"
    find("trix-editor").click.send_keys("Please fill in the survey")
    click_on "Submit"   # deliberately NOT ticking Active?

    # An inactive banner is invisible, so saying nothing made the feature look broken. This is an
    # :alert (amber, stays put) rather than a :notice (green, auto-dismisses) because it needs reading.
    expect(page).to have_css(".header-flash .alert[role='alert']", text: "it is not active, so no one will see it yet")
    row = find("#banners tbody tr", text: "Survey reminder")
    expect(row.find("td.min-width")).to have_text("Inactive")
    expect(row).to have_button("Activate")

    within(row) { click_on "Activate" }
    expect(page).to have_css(".header-flash", text: "now showing at the top of every page")
    expect(find("#banners tbody tr", text: "Survey reminder").find("td.min-width")).to have_text("Active")
    expect(Banner.find_by(name: "Survey reminder").active).to be true

    visit root_path
    expect(page).to have_css('[data-controller~="dismiss"]')
  end
end

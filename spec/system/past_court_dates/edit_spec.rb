require "rails_helper"

RSpec.describe "past_court_dates/edit", type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let!(:casa_case) { create(:casa_case, casa_org: organization) }
  let!(:past_court_date) { create(:past_court_date, :with_court_details, casa_case: casa_case) }

  before do
    sign_in admin
    visit root_path
    click_on "Cases"
    click_on casa_case.case_number
    click_on "Edit Case Details"
    click_on past_court_date.date.strftime("%B %-d, %Y")
    click_on "Edit"
  end

  it "shows court mandates" do
    court_order = past_court_date.case_court_orders.first

    expect(page).to have_text(court_order.text)
    expect(page).to have_text(court_order.implementation_status.humanize)
  end

  it "edits past court date", js: true do
    expect(page).to have_select("Hearing type")
    expect(page).to have_select("Judge")

    page.find("#add-mandate-button").click
    find("#mandates-list-container").first("textarea").send_keys("Court Mandate Text One")

    within ".top-page-actions" do
      click_on "Update"
    end
    expect(page).to have_text("Court Mandate Text One")
  end
end

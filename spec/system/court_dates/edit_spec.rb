# frozen_string_literal: true

require "rails_helper"

RSpec.describe "court_dates/edit", type: :system do
  context "with date"
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:volunteer) { create(:volunteer) }
  let(:supervisor) { create(:supervisor, casa_org: organization) }
  let!(:casa_case) { create(:casa_case, case_number: 'CINA-08-1001', casa_org: organization) }
  let!(:past_court_date) { create(:court_date, :with_court_details, casa_case: casa_case, date: Date.new(2020, 12, 25)) }
  let!(:future_court_date) { create(:court_date, :with_court_details, casa_case: casa_case, date: Date.new(2021, 1, 8)) }

  before do
    travel_to(Date.new(2021, 1, 1))
  end

  context "as an admin" do
    before do
      sign_in admin
      visit casa_case_path(casa_case)
      click_on "December 25, 2020"
      click_on "Edit"
    end

    it "shows court orders" do
      court_order = past_court_date.case_court_orders.first

      expect(page).to have_text(court_order.text)
      expect(page).to have_text(court_order.implementation_status.humanize)
    end

    it "adds a standard court order", :js do
      select("Family therapy", from: "Court Order Type")
      click_button("Add a court order")

      textarea = all("textarea.court-order-text-entry").last
      expect(textarea.value).to eq("Family therapy")
    end

    it "adds a custom court order", :js do
      click_button("Add a court order")

      textarea = all("textarea.court-order-text-entry").last
      expect(textarea.value).to eq("")
    end

    it "edits past court date", :js do
      expect(page).to have_text("Editing Court Date")
      expect(page).to have_text("Case Number:")
      expect(page).to have_text('CINA-08-1001')
      expect(page).to have_text("Add Court Date")
      expect(page).to have_field("court_date_date", with: "2020-12-25")
      expect(page).to have_text("Add Court Report Due Date")
      expect(page).to have_field("court_date_court_report_due_date")
      expect(page).to have_select("Judge")
      expect(page).to have_select("Hearing type")
      expect(page).to have_text("Court Orders - Please check that you didn't enter any youth names")
      expect(page).to have_text("Add a court order")

      page.find('button[data-action="court-order-form#add"]').click
      find("#court-orders-list-container").first("textarea").send_keys("Court Order Text One")

      within ".top-page-actions" do
        click_on "Update"
      end

      expect(page).to have_text("Court Order Text One")
    end

    it "allows deleting a future court date", :js do
      visit root_path
      click_on "Cases"
      click_on 'CINA-08-1001'

      expect(page).to have_content("December 25, 2020")
      expect(page).to have_content("January 8, 2021")

      page.find("a", text: "January 8, 2021").click
      accept_alert "Are you sure?" do
        page.find("a", text: "Delete Future Court Date").click
      end
      expect(page).to have_content "Court date was successfully deleted"

      expect(page).not_to have_content("January 8, 2021")
      expect(page).to have_content("December 25, 2020")
    end
  end

  context "as a supervisor" do
    it "allows deleting a future court date", :js do
      sign_in supervisor

      visit root_path
      click_on "Cases"
      click_on 'CINA-08-1001'

      expect(page).to have_content("December 25, 2020")
      expect(page).to have_content("January 8, 2021")

      page.find("a", text: "January 8, 2021").click
      accept_alert "Are you sure?" do
        page.find("a", text: "Delete Future Court Date").click
      end

      expect(page).to have_content "Court date was successfully deleted."
      expect(page).not_to have_content("January 8, 2021")
      expect(page).to have_content("December 25, 2020")
    end
  end

  context "as a volunteer" do
    it "can't delete a future court date as volunteer", :js do
      volunteer.casa_cases = [casa_case]
      sign_in volunteer

      visit root_path
      click_on "Cases"
      click_on 'CINA-08-1001'

      expect(page).to have_content("December 25, 2020")
      expect(page).to have_content("January 8, 2021")

      page.find("a", text: "January 8, 2021").click

      expect(page).not_to have_content "Delete Future Court Date"
    end
  end
end

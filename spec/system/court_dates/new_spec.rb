# frozen_string_literal: true

require "rails_helper"

RSpec.describe "court_dates/new", type: :system do
  let(:now) { Date.new(2021, 1, 1) }
  let(:casa_org) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: casa_org) }
  let!(:casa_case) { create(:casa_case, casa_org: casa_org) }
  let!(:court_date) { create(:court_date, :with_court_details, casa_case: casa_case, date: now - 1.week) }
  let!(:judge) { create(:judge) }
  let!(:hearing_type) { create(:hearing_type) }
  let(:text) { Faker::Lorem.paragraph(sentence_count: 2) }

  before do
    travel_to now
    sign_in admin
    visit casa_case_path(casa_case)
    click_link("Add a court date")
  end

  context "when all fields are filled" do
    it "is successful", js: true do
      expect(page.body).to have_content(casa_case.case_number)

      fill_in "court_date_date", with: :now
      fill_in "court_date_court_report_due_date", with: :now
      select judge.name, from: "Judge"
      select hearing_type.name, from: "Hearing type"

      page.find('button[data-action="extended-nested-form#add"]').click

      text_area = first(:css, "textarea").native
      text_area.send_keys(text)
      page.find("select.implementation-status").find(:option, text: "Partially implemented").select_option

      within ".top-page-actions" do
        click_on "Create"
      end

      expect(page).to have_content("Court date was successfully created.")
      expect(page.body).to have_content(casa_case.case_number)
      expect(page).to have_content("Court Report Due Date:")
      expect(page).to have_content(judge.name)
      expect(page).to have_content(hearing_type.name)
      expect(page).to have_content(text)
      expect(page).to have_content("Partially implemented")
    end
  end

  context "without changing default court date" do
    it "does create a new court_date" do
      within ".top-page-actions" do
        click_on "Create"
      end

      expect(page).to have_content("Court date was successfully created.")
    end
  end
end

require "rails_helper"

RSpec.describe "court_dates/edit", type: :system do
  context "with date"
  let(:now) { Date.new(2021, 1, 1) }
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:volunteer) { create(:volunteer) }
  let(:supervisor) { create(:casa_admin, casa_org: organization) }
  let!(:casa_case) { create(:casa_case, casa_org: organization) }
  let!(:court_date) { create(:court_date, :with_court_details, casa_case: casa_case, date: now - 1.week) }
  let!(:future_court_date) { create(:court_date, :with_court_details, casa_case: casa_case, date: now + 1.week) }

  before do
    travel_to now
  end


  context "as a volunteer" do
    it "can download a report which focuses on the court date", js: true do
      volunteer.casa_cases = [casa_case]
      sign_in volunteer

      visit root_path
      click_on "Cases"
      click_on casa_case.case_number

      expect(CourtDate.count).to eq 2
      click_on "January 8, 2021"
      expect(page).to have_content "Court Date"

      click_on "Download Report"

      wait_for_download

      expect(download_docx.paragraphs.map(&:to_s)).to include("Hearing Date: January 8, 2021")
    end
  end
end
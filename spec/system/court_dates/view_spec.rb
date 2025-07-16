require "rails_helper"

RSpec.describe "court_dates/edit", type: :system do
  let(:now) { Date.new(2021, 1, 1) }
  let(:organization_containing_court_date) { create(:casa_org) }
  let(:organization_not_containing_court_date) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization_containing_court_date) }
  let(:volunteer) { create(:volunteer, casa_org: organization_containing_court_date) }
  let!(:casa_case) { create(:casa_case, casa_org: organization_containing_court_date) }
  let!(:court_date) { create(:court_date, :with_court_details, casa_case: casa_case, date: now + 1.week) }

  before do
    travel_to now
  end

  shared_examples "user can view court date" do |user_type, organization|
    let(:user) { create(user_type, casa_org: organization) }

    before(:all) do
      sign_in user
      visit casa_case_court_date_path(casa_case, court_date)
    end

    it "can visit the court order page" do
      expect(page).not_to have_content "Sorry, you are not authorized to perform this action."
    end

    it "can see the court date" do
    end

    it "can see the associated case number" do
    end

    it "can see the associated court report due date" do
    end

    it "can see the associated judge" do
    end

    it "can see the associated hearing type" do
    end

    it "can see associated court orders" do
    end
  end

  shared_examples "user cannot view court date" do |user_type, organization|
    let(:user) { create(user_type, casa_org: organization) }

    it "is not allowed to visit the court order page" do
      expect(page).to have_content "Sorry, you are not authorized to perform this action."
    end
  end

  context "as a volunteer" do
    it "can download a report which focuses on the court date", :js do
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

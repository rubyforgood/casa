require "rails_helper"

RSpec.describe "court_dates/new", type: :system do
  let(:casa_org) { create(:casa_org) }
  let!(:casa_case) { create(:casa_case, casa_org: casa_org) }
  let!(:judge) { create(:judge) }
  let!(:hearing_type) { create(:hearing_type) }
  let(:admin) { create(:casa_admin, casa_org: casa_org) }
  let(:text) { Faker::Lorem.paragraph(sentence_count: 2) }

  before do
    travel_to Date.new(2021, 1, 1)
    sign_in admin
    visit root_path
    click_on "Cases"
    click_on casa_case.case_number
    click_on "Edit Case Details"
    find(".past-court-dates.add-container .btn-primary").click
  end

  context "when all fields are filled" do
    it "is successful", js: true do
      expect(page.body).to have_content(casa_case.case_number)

      fill_in "court_date_date", with: "04/04/2020"

      select judge.name, from: "Judge"
      select hearing_type.name, from: "Hearing type"

      find("#add-mandate-button").click

      fill_in "court_date_case_court_orders_attributes_0_text", with: text
      select "Partially implemented", from: "court_date_case_court_orders_attributes_0_implementation_status"

      within ".top-page-actions" do
        click_on "Create"
      end

      expect(page.body).to have_content(casa_case.case_number)
      expect(page).to have_content("Court date was successfully created.")
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

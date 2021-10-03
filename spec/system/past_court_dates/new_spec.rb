require "rails_helper"

RSpec.describe "past_court_dates/new", type: :system do
  let(:casa_org) { create(:casa_org) }
  let!(:casa_case) { create(:casa_case, casa_org: casa_org) }
  let!(:judge) { create(:judge) }
  let!(:hearing_type) { create(:hearing_type) }
  let(:admin) { create(:casa_admin, casa_org: casa_org) }
  let(:mandate_text) { Faker::Lorem.paragraph(sentence_count: 2) }

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

      select "3", from: "past_court_date_date_3i"
      select "March", from: "past_court_date_date_2i"
      select "2020", from: "past_court_date_date_1i"

      select judge.name, from: "Judge"
      select hearing_type.name, from: "Hearing type"

      find("#add-mandate-button").click
      fill_in "casa_case_case_court_orders_attributes_0_mandate_text", with: mandate_text
      select "Partially implemented", from: "casa_case_case_court_orders_attributes_0_implementation_status"

      within ".top-page-actions" do
        click_on "Create"
      end

      expect(page.body).to have_content(casa_case.case_number)
      expect(page).to have_content("Past court date was successfully created.")
      expect(page).to have_content(judge.name)
      expect(page).to have_content(hearing_type.name)
      expect(page).to have_content(mandate_text)
      expect(page).to have_content("Partially implemented")
    end
  end

  context "when non-mandatory fields are not filled" do
    it "does not create a new past_court_date" do
      within ".top-page-actions" do
        click_on "Create"
      end

      expect(page).to have_current_path(casa_case_past_court_dates_path(casa_case), ignore_query: true)
      expect(page).to have_content("Date can't be blank")
    end
  end
end

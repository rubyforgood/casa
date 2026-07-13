require "rails_helper"

RSpec.describe "casa_cases/index", type: :system do
  # TODO combine with other casa cases index system spec
  let(:organization) { create(:casa_org) }
  let(:volunteer) { build :volunteer, casa_org: organization }
  let(:admin) { create(:casa_admin, casa_org: organization) }

  context "logged in as admin" do
    before do
      sign_in admin
      visit casa_cases_path
    end

    it "has content" do
      expect(page).to have_text("Cases")
      expect(page).to have_link("New Case", href: new_casa_case_path)
      expect(page).to have_select("Status")
      expect(page).to have_select("Case number prefix")
      expect(page).to have_selector("th", text: "Case number")
      expect(page).to have_selector("th", text: "Next court date")
      expect(page).to have_selector("th", text: "Status")
      expect(page).to have_selector("th", text: "Transition aged youth")
      expect(page).to have_selector("th", text: "Assigned to")
    end

    it "opens only one header dropdown at a time", :js do
      find("summary", text: "More").click
      expect(page).to have_link("Case Groups")

      find("summary[aria-label='Account menu']").click
      expect(page).to have_link("Sign out")
      expect(page).to have_no_link("Case Groups")
    end

    it "sorts cases by clicking a column header" do
      create(:casa_case, casa_org: organization, case_number: "CINA-AAA")
      create(:casa_case, casa_org: organization, case_number: "CINA-ZZZ")
      visit casa_cases_path

      expect(page).to have_selector("th[aria-sort='ascending']", text: "Case number")
      expect(page.text.index("CINA-AAA")).to be < page.text.index("CINA-ZZZ")

      click_on "Case number"
      expect(page).to have_selector("th[aria-sort='descending']", text: "Case number")
      expect(page.text.index("CINA-ZZZ")).to be < page.text.index("CINA-AAA")
    end

    it "ignores an unknown sort parameter" do
      create(:casa_case, casa_org: organization, case_number: "CINA-1")
      visit casa_cases_path(sort: "bogus", direction: "sideways")
      expect(page).to have_selector("th[aria-sort='ascending']", text: "Case number")
    end

    it "renders every sortable column without error" do
      create(:casa_case, casa_org: organization)
      %w[case_number next_court_date status transition assigned].each do |column|
        visit casa_cases_path(sort: column, status: "all")
        expect(page).to have_selector("table")
      end
    end

    it "searches by case number and volunteer name" do
      zelda = create(:volunteer, casa_org: organization, display_name: "Zelda Fitzgerald")
      create(:casa_case, casa_org: organization, case_number: "CINA-FINDME-1")
      by_volunteer = create(:casa_case, casa_org: organization, case_number: "TPR-OTHER-2")
      create(:case_assignment, volunteer: zelda, casa_case: by_volunteer)
      create(:casa_case, casa_org: organization, case_number: "TPR-NOPE-9")

      visit casa_cases_path(search: "FINDME")
      expect(page).to have_content("CINA-FINDME-1")
      expect(page).to have_no_content("TPR-NOPE-9")
      expect(page).to have_content("matching")

      visit casa_cases_path(search: "Zelda")
      expect(page).to have_content("TPR-OTHER-2")
      expect(page).to have_no_content("TPR-NOPE-9")
    end

    it "filters by status", :js do
      active_case = create(:casa_case, active: true, casa_org: organization, case_number: "CINA-ACTIVE")
      inactive_case = create(:casa_case, active: false, casa_org: organization, case_number: "CINA-INACTIVE")

      visit casa_cases_path
      # active by default
      expect(page).to have_content(active_case.case_number)
      expect(page).to have_no_content(inactive_case.case_number)

      select "Inactive", from: "Status"
      expect(page).to have_content(inactive_case.case_number)
      expect(page).to have_no_content(active_case.case_number)
    end

    it "Only displays cases belonging to user's org" do
      org_cases = create_list :casa_case, 3, active: true, casa_org: organization
      new_org = create :casa_org
      other_org_cases = create_list :casa_case, 3, active: true, casa_org: new_org

      visit casa_cases_path

      org_cases.each { |casa_case| expect(page).to have_content casa_case.case_number }
      other_org_cases.each { |casa_case| expect(page).not_to have_content casa_case.case_number }
    end
  end

  context "logged in as volunteer" do
    before do
      sign_in volunteer
      visit casa_cases_path
    end

    it "hides filters" do
      expect(page).not_to have_select("Status")
      expect(page).not_to have_text("Assignment")
      expect(page).not_to have_text("Case number prefix")
    end
  end
end

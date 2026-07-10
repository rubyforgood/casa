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
      expect(page).to have_selector("th", text: "Case Number")
      expect(page).to have_selector("th", text: "Hearing Type")
      expect(page).to have_selector("th", text: "Judge")
      expect(page).to have_selector("th", text: "Status")
      expect(page).to have_selector("th", text: "Transition Aged Youth")
      expect(page).to have_selector("th", text: "Assigned To")
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

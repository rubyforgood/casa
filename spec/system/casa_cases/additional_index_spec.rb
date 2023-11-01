require "rails_helper"

RSpec.describe "casa_cases/index", type: :system do
  # TODO combine with other casa cases index system spec
  let(:user) { build_stubbed :casa_admin }

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
      expect(page).to have_selector("button", text: "Casa Case Prefix")
      expect(page).to have_selector("th", text: "Case Number")
      expect(page).to have_selector("th", text: "Hearing Type")
      expect(page).to have_selector("th", text: "Judge")
      expect(page).to have_selector("th", text: "Status")
      expect(page).to have_selector("th", text: "Transition Aged Youth")
      expect(page).to have_selector("th", text: "Assigned To")
    end

    it "filters active/inactive", js: true do
      active_case = build(:casa_case, active: true, casa_org: organization)
      active_case1 = build(:casa_case, active: true, casa_org: organization)
      inactive_case = build(:casa_case, active: false, casa_org: organization)

      create(:case_assignment, volunteer: volunteer, casa_case: active_case)
      create(:case_assignment, volunteer: volunteer, casa_case: active_case1)
      create(:case_assignment, volunteer: volunteer, casa_case: inactive_case)

      visit casa_cases_path
      expect(page).to have_selector(".casa-case-filters")

      # by default, only active casa cases are shown
      expect(page.all("table#casa-cases tbody tr").count).to eq [active_case, active_case1].size

      click_on "Status"
      find(:css, 'input[data-value="Active"]').click
      expect(page).to have_text("No matching records found")

      find(:css, 'input[data-value="Inactive"]').click
      expect(page.all("table#casa-cases tbody tr").count).to eq [inactive_case].size
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
      expect(page).to_not have_text("Assigned to Volunteer")
      expect(page).to_not have_text("Assigned to more than 1 Volunteer")
      expect(page).to_not have_text("Assigned to Transition Aged Youth")
      expect(page).to_not have_text("Casa Case Prefix")
      expect(page).to_not have_text("Select columns")
      expect(page).to_not have_selector(".casa-case-filters")
    end
  end
end

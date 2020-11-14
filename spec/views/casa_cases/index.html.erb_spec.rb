require "rails_helper"

RSpec.describe "casa_cases/index", type: :system do
  # subject { render template: "casa_cases/index" }
  let(:user) { build_stubbed :casa_admin }

  let(:organization) { create(:casa_org) }
  let(:volunteer) { create :volunteer, casa_org: organization }
  let(:admin) { create(:casa_admin, casa_org: organization) }

  before do
    sign_in admin
  end

  after(:each) do
    # customize based on which type of logs you want displayed
    log_types = page.driver.browser.manage.logs.available_types
    log_types.each do |t|
      puts t.to_s + ": " + page.driver.browser.manage.logs.get(t).join("\n")
    end
  end

  it "Displays the Cases title" do
    visit casa_cases_path
    expect(page).to have_text("Cases")
  end

  it "Has a New Case Contact button" do
    visit casa_cases_path
    expect(page).to have_link("New Case", href: new_casa_case_path)
  end

  it "Displays Casa Cases table titles" do
    visit casa_cases_path
    expect(page).to have_selector("th", text: "Case Number")
    expect(page).to have_selector("th", text: "Hearing Type")
    expect(page).to have_selector("th", text: "Judge")
    expect(page).to have_selector("th", text: "Status")
    expect(page).to have_selector("th", text: "Transition Aged Youth")
    expect(page).to have_selector("th", text: "Assigned To")
    expect(page).to have_selector("th", text: "Actions")
  end

  it "Filters active/inactive casa_cases" do
    active_case = create(:casa_case, active: true, casa_org: organization)
    active_case1 = create(:casa_case, active: true, casa_org: organization)
    inactive_case = create(:casa_case, active: false, casa_org: organization)

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
    other_org_cases = create_list :casa_case, 3, active: true

    visit casa_cases_path

    org_cases.each { |casa_case| expect(page).to have_content casa_case.case_number }
    other_org_cases.each { |casa_case| expect(page).not_to have_content casa_case.case_number }
  end
end

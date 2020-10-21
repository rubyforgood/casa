require "rails_helper"

RSpec.describe "admin views Volunteers page", type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }

  context "when no logo_url" do
    it "can see volunteers and navigate to their cases" do
      volunteer = create(:volunteer, :with_assigned_supervisor, display_name: "User 1", email: "casa@example.com", casa_org: organization)
      volunteer.casa_cases << create(:casa_case, casa_org: organization)
      volunteer.casa_cases << create(:casa_case, casa_org: organization)
      casa_case = volunteer.casa_cases[0]

      sign_in admin

      visit volunteers_path

      expect(page).to have_text("User 1")
      expect(page).to have_text(casa_case.case_number)

      within "#volunteers" do
        click_on volunteer.casa_cases.first.case_number
      end

      expect(page).to have_text("CASA Case Details")
      expect(page).to have_text("Miles Driven")
      expect(page).to have_text("Want reimbursement?")
    end

    it "displays default logo" do
      sign_in admin

      visit volunteers_path

      expect(page).to have_xpath("//img[@src = '/packs-test/media/src/images/default-logo-c9048fc43854499e952e4b62a505bf35.png' and @alt='CASA Logo']")
    end
  end

  it "can show/hide columns on volunteers table" do
    sign_in admin

    visit volunteers_path
    expect(page).to have_text("Pick displayed columns")

    click_on "Pick displayed columns"
    expect(page).to have_text("Name")
    expect(page).to have_text("Status")
    expect(page).to have_text("Contact Made In Past 60 Days")
    expect(page).to have_text("Last Contact Made")
    check "Name"
    check "Status"
    uncheck "Contact Made In Past 60 Days"
    uncheck "Last Contact Made"
    within(".modal-dialog") do
      click_button "Close"
    end

    expect(page).to have_text("Name")
    expect(page).to have_text("Status")
    expect(page).not_to have_text("Contact Made In Past 60 Days")
    expect(page).not_to have_text("Last Contact Made")
  end

  it "can filter volunteers" do
    assigned_volunteers = create_list(:volunteer, 3, :with_assigned_supervisor, casa_org: organization)
    inactive_volunteers = create_list(:volunteer, 2, :inactive, casa_org: organization)
    unassigned_volunteers = create_list(:volunteer, 1)

    sign_in admin

    visit volunteers_path
    expect(page).to have_selector(".volunteer-filters")

    # by default, only active users are shown
    expect(page.all("table#volunteers tbody tr").count).to eq assigned_volunteers.count

    click_on "Supervisor"
    find(:css, "#unassigned-vol-filter").set(true)

    expect(page.all("table#volunteers tbody tr").count).to eq unassigned_volunteers.count

    click_on "Status"
    find(:css, 'input[data-value="Active"]').set(false)

    expect(page).to have_text("No matching records found")

    find(:css, 'input[data-value="Inactive"]').set(true)

    expect(page.all("table#volunteers tbody tr").count).to eq inactive_volunteers.count
  end

  it "can go to the volunteer edit page from the volunteer list" do
    create(:volunteer, :with_assigned_supervisor, casa_org: organization)
    sign_in admin

    visit volunteers_path

    within "#volunteers" do
      click_on "Edit"
    end

    expect(page).to have_text("Editing Volunteer")
  end

  it "can go to the new volunteer page" do
    sign_in admin

    visit volunteers_path

    click_on "New Volunteer"

    expect(page).to have_text("New Volunteer")
    expect(page).to have_css("form#new_volunteer")
  end

  describe "supervisor column of volunteers table" do
    it "is blank when volunteer has no supervisor" do
      create(:volunteer, casa_org: organization)
      sign_in admin

      visit volunteers_path
      click_on "Supervisor"
      find(:css, "#unassigned-vol-filter").set(true)
      supervisor_cell = page.find(".supervisor-column")

      expect(supervisor_cell.text).to eq ""
    end

    it "displays supervisor's name when volunteer has supervisor" do
      name = "Superduper Visor"
      supervisor = create(:supervisor, display_name: name, casa_org: organization)
      create(:volunteer, supervisor: supervisor, casa_org: organization)
      sign_in admin

      visit volunteers_path
      supervisor_cell = page.find(".supervisor-column")

      expect(supervisor_cell.text).to eq name
    end

    it "is blank when volunteer's supervisor is inactive" do
      create(:volunteer, :with_inactive_supervisor, casa_org: organization)
      sign_in admin

      visit volunteers_path
      click_on "Supervisor"
      find(:css, "#unassigned-vol-filter").set(true)
      supervisor_cell = page.find(".supervisor-column")

      expect(supervisor_cell.text).to eq ""
    end
  end
end

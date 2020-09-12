require "rails_helper"

RSpec.describe "admin views dashboard", type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }

  before { travel_to Time.zone.local(2020, 8, 29, 4, 5, 6) }
  after { travel_back }

  context "when no logo_url" do
    it "can see volunteers and navigate to their cases" do
      volunteer = create(:volunteer, email: "casa@example.com", casa_org: organization)
      volunteer.casa_cases << create(:casa_case, casa_org: organization)
      volunteer.casa_cases << create(:casa_case, casa_org: organization)
      casa_case = volunteer.casa_cases[0]

      sign_in admin

      visit root_path

      expect(page).to have_text("casa@example.com")
      expect(page).to have_text(casa_case.case_number)

      within "#volunteers" do
        click_on volunteer.casa_cases.first.case_number
      end

      expect(page).to have_text("CASA Case Details")
      expect(page).to have_text("Miles Driven")
      expect(page).to have_text("Want reimbursement?")
    end
  end

  context "when logo_url" do
    let(:logo) { create(:casa_org_logo) }
    let(:organization) { create(:casa_org, casa_org_logo: logo, display_name: "FOO", address: "123 Main St", footer_links: [["www.example.com", "First Link"], ["www.foobar.com", "Second Link"]]) }

    it "displays logo, display name, address footer links" do
      create(:volunteer, email: "casa@example.com", casa_org: organization)
      sign_in admin
      visit root_path
      expect(page).to have_text "FOO"
      expect(page).to have_text "123 Main St"
      expect(page).to have_link "First Link", href: "www.example.com"
      expect(page).to have_link "Second Link", href: "www.foobar.com"
      expect(page).to have_text "Volunteer"
    end
  end

  describe "supervisor column of volunteers table" do
    it "is blank when volunteer has no supervisor" do
      create(:volunteer, casa_org: organization)
      sign_in admin

      visit root_path
      supervisor_cell = page.find("#supervisor-column")

      expect(supervisor_cell.text).to eq ""
    end

    it "displays supervisor's name when volunteer has supervisor" do
      name = "Superduper Visor"
      supervisor = create(:supervisor, display_name: name, casa_org: organization)
      create(:volunteer, supervisor: supervisor, casa_org: organization)
      sign_in admin

      visit root_path
      supervisor_cell = page.find("#supervisor-column")

      expect(supervisor_cell.text).to eq name
    end

    it "is blank when volunteer has been unassigned from supervisor" do
      volunteer = create(:volunteer, casa_org: organization)
      create(:supervisor_volunteer, volunteer: volunteer, is_active: false)
      sign_in admin

      visit root_path
      supervisor_cell = page.find("#supervisor-column")

      expect(supervisor_cell.text).to eq ""
    end
  end

  it "can see the last case contact and navigate to it", js: false do
    volunteer = create(:volunteer, email: "casa@example.com", casa_org: organization)
    casa_case = create(:casa_case, casa_org: organization, case_number: SecureRandom.hex(12))
    create(:case_contact, :wants_reimbursement, casa_case: casa_case, creator: volunteer, contact_made: true)

    volunteer.casa_cases << casa_case

    sign_in admin

    visit root_path

    # save_and_open_page

    expect(page).to have_text(casa_case.case_number)
    expect(page).to have_text("August 29, 2020")

    within "#volunteers" do
      click_on "August 29, 2020"
    end

    expect(page).to have_text("CASA Case Details")
  end

  it "can go to the volunteer edit page from the volunteer list" do
    create(:volunteer, casa_org: organization)
    sign_in admin

    visit root_path

    within "#volunteers" do
      click_on "Edit"
    end

    expect(page).to have_text("Editing Volunteer")
  end

  it "can go to the new volunteer page" do
    sign_in admin

    visit root_path

    click_on "New Volunteer"

    expect(page).to have_text("New Volunteer")
    expect(page).to have_css("form#new_volunteer")
  end

  it "can filter volunteers" do
    create_list(:volunteer, 3, casa_org: organization)
    create_list(:volunteer, 2, :inactive, casa_org: organization)

    sign_in admin

    visit root_path
    expect(page).to have_selector(".volunteer-filters")

    # by default, only active users are shown, so result should be 4 here
    expect(page.all("table#volunteers tr").count).to eq 4

    click_on "Status"
    find(:css, 'input[data-value="Active"]').set(false)

    # when all users are hidden, the tr count will be 2 for header and "no results" row
    expect(page.all("table#volunteers tr").count).to eq 2

    find(:css, 'input[data-value="Inactive"]').set(true)

    expect(page.all("table#volunteers tr").count).to eq 3
  end

  it "can go to the supervisor edit page from the supervisor list" do
    supervisor_name = "Leslie Knope"
    create(:supervisor, display_name: supervisor_name, casa_org: organization)
    sign_in admin

    visit root_path

    expect(page).to have_text(supervisor_name)

    within "#supervisors" do
      click_on "Edit"
    end

    expect(page).to have_text("Editing Supervisor")
  end

  it "can go to the supervisor edit page from the supervisor's name" do
    supervisor_name = "Leslie Knope"
    create(:supervisor, display_name: supervisor_name, casa_org: organization)
    sign_in admin

    visit root_path

    within "#supervisors" do
      click_on supervisor_name
    end

    expect(page).to have_text("Editing Supervisor")
  end

  it "can go to the supervisor edit page and see red message
      when there are no active volunteers" do
    create(:supervisor, casa_org: organization)
    sign_in admin

    visit root_path

    within "#supervisors" do
      click_on "Edit"
    end

    expect(page).to have_text("There are no active, unassigned volunteers available")
  end
end

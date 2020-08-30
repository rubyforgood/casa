require "rails_helper"

RSpec.describe "admin views dashboard", type: :system do
  let(:admin) { create(:casa_admin) }
  before { travel_to Time.zone.local(2020,8,29,4,5,6) }
  after { travel_back }

  it "can see volunteers and navigate to their cases", js: false do
    volunteer = create(:volunteer, :with_casa_cases, email: "casa@example.com")
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

  describe "supervisor column of volunteers table", js: false do
    it "is blank when volunteer has no supervisor" do
      volunteer = create(:volunteer)
      sign_in admin

      visit root_path
      supervisor_cell = page.find("#supervisor-column")

      expect(supervisor_cell.text).to eq ""
    end

    it "displays supervisor's name when volunteer has supervisor", js: false do
      name = "Superduper Visor"
      supervisor = create(:supervisor, display_name: name)
      volunteer = create(:volunteer, supervisor: supervisor)
      sign_in admin

      visit root_path
      supervisor_cell = page.find("#supervisor-column")

      expect(supervisor_cell.text).to eq name
    end
  end

  it "can see the last case contact and navigate to it", js: false do
    volunteer = create(:volunteer, :with_case_contact_wants_driving_reimbursement, email: "casa@example.com")
    sign_in admin

    visit root_path

    expect(page).to have_text("August 29, 2020")
    expect(page).to have_text("20") # miles driven

    within "#volunteers" do
      click_on "August 29, 2020"
    end

    expect(page).to have_text("CASA Case Details")
  end

  it "can go to the volunteer edit page from the volunteer list", js: false do
    create(:volunteer)
    sign_in admin

    visit root_path

    within "#volunteers" do
      click_on "Edit"
    end

    expect(page).to have_text("Editing Volunteer")
  end

  it "can go to the new volunteer page", js: false do
    sign_in admin

    visit root_path

    click_on "New Volunteer"

    expect(page).to have_text("New Volunteer")
    expect(page).to have_css("form#new_volunteer")
  end

  it "can filter volunteers" do
    create_list(:volunteer, 3)
    create_list(:volunteer, 2, :inactive)

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

  it "can see supervisors", js: false do
    supervisor_name = "Leslie Knope"
    create(:supervisor, display_name: supervisor_name)
    sign_in admin

    visit root_path

    expect(page).to have_text(supervisor_name)
  end

  it "can go to the supervisor edit page from the supervisor list", js: false do
    supervisor_name = "Leslie Knope"
    create(:supervisor, display_name: supervisor_name)
    sign_in admin

    visit root_path

    within "#supervisors" do
      click_on "Edit"
    end

    expect(page).to have_text("Editing Supervisor")
  end

  it "can go to the supervisor edit page from the supervisor's name", js: false do
    supervisor_name = "Leslie Knope"
    create(:supervisor, display_name: supervisor_name)
    sign_in admin

    visit root_path

    within "#supervisors" do
      click_on supervisor_name
    end

    expect(page).to have_text("Editing Supervisor")
  end

  it "can go to the supervisor edit page and see red message
      when there are no active volunteers", js: false do
    create(:supervisor)
    sign_in admin

    visit root_path

    within "#supervisors" do
      click_on "Edit"
    end

    expect(page).to have_text("There are no active, unassigned volunteers available")
  end
end

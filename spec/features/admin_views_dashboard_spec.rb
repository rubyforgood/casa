require "rails_helper"

RSpec.describe "admin views dashboard", type: :feature do
  let(:admin) { create(:user, :casa_admin) }

  it "can see volunteers and navigate to their cases" do
    volunteer = create(:user, :volunteer, :with_casa_cases, email: "casa@example.com")
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

  describe "supervisor column of volunteers table" do
    it "is blank when volunteer has no supervisor" do
      volunteer = create(:user, :volunteer)
      sign_in admin

      visit root_path
      supervisor_cell = page.find("#supervisor-column")

      expect(supervisor_cell.text).to eq ""
    end

    it "displays supervisor's name when volunteer has supervisor" do
      name = "Superduper Visor"
      supervisor = create(:user, :supervisor, display_name: name)
      volunteer = create(:user, :volunteer, supervisor: supervisor)
      sign_in admin

      visit root_path
      supervisor_cell = page.find("#supervisor-column")

      expect(supervisor_cell.text).to eq name
    end
  end

  it "can see the last case contact and navigate to it" do
    volunteer = create(:user, :volunteer, :with_case_contact_wants_driving_reimbursement, email: "casa@example.com")
    sign_in admin

    visit root_path

    expect(page).to have_text(volunteer.most_recent_contact.occurred_at.strftime("%B %-e, %Y"))
    expect(page).to have_text("20") # miles driven

    within "#volunteers" do
      click_on volunteer.most_recent_contact.occurred_at.strftime("%B %-e, %Y")
    end

    expect(page).to have_text("CASA Case Details")
  end

  it "can go to the volunteer edit page from the volunteer list" do
    create(:user, :volunteer)
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
    expect(page).to have_css("form#new_user")
  end

  it "can filter volunteers", type: :system do
    create_list(:user, 3, :volunteer)
    create_list(:user, 2, :inactive)

    sign_in admin

    visit root_path
    expect(page).to have_selector(".volunteer-filters")

    # by default, only active users are shown, so result should be 4 here
    # expect(page.all("table#volunteers tr").count).to eq 4 # TODO fix this test- probably caused by js error somewhere

    click_on "Status"
    find(:css, 'input[data-value="Active"]').set(false)

    # when all users are hidden, the tr count will be 2 for header and "no results" row
    expect(page.all("table#volunteers tr").count).to eq 2

    find(:css, 'input[data-value="Inactive"]').set(true)

    expect(page.all("table#volunteers tr").count).to eq 3
  end
end

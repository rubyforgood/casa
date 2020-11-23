require "rails_helper"

RSpec.describe "admin views dashboard", type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }

  before { travel_to Time.zone.local(2020, 8, 29, 4, 5, 6) }

  after { travel_back }

  it "sees volunteer names as links in Cases table" do
    volunteer = create(:volunteer, display_name: "Bob Loblaw", casa_org: organization)
    casa_case = create(:casa_case, active: true, casa_org: organization, case_number: "CINA-1")
    create(:case_assignment, volunteer: volunteer, casa_case: casa_case)

    sign_in admin
    visit casa_cases_path

    expect(page).to have_text("Bob Loblaw")
    expect(page).to have_link("Bob Loblaw", href: "/volunteers/#{volunteer.id}/edit")
  end

  it "displays other admins within the same CASA organization" do
    admin2 = create(:casa_admin, email: "Jon@org.com", casa_org: organization)
    admin3 = create(:casa_admin, email: "Bon@org.com", casa_org: organization)
    different_org_admin = create(:casa_admin, email: "Jovi@something.else", casa_org: create(:casa_org))
    supervisor = create(:supervisor, email: "super@visor.com", casa_org: organization)
    volunteer = create(:volunteer, email: "volun@tear.com", casa_org: organization)

    sign_in admin
    visit casa_admins_path

    within "#admins" do
      expect(page).to have_content(admin2.email)
      expect(page).to have_content(admin3.email)
      expect(page).to have_no_content(different_org_admin.email)
      expect(page).to have_no_content(supervisor.email)
      expect(page).to have_no_content(volunteer.email)
    end
  end
end

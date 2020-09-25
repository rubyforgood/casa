require "rails_helper"

RSpec.describe "admin views dashboard", type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }

  before { travel_to Time.zone.local(2020, 8, 29, 4, 5, 6) }
  after { travel_back }

  context "in the footer" do
    let(:organization) { create(:casa_org) }

    xit "displays rfg logo, company logo, display name, address, footer, links" do
      create(:volunteer, email: "casa@example.com", casa_org: organization)
      sign_in admin
      visit root_path

      expect(page).to have_text "CASA"
      expect(page).to have_text "123 Main St"
      expect(page).to have_link "First Link", href: "www.example.com"
      expect(page).to have_link "Second Link", href: "www.foobar.com"
      expect(page).to have_text "Volunteer"
      expect(page).to have_css "footer .rfglink"
    end
  end

  it "displays other admins within the same CASA organization" do
    admin2 = create(:casa_admin, email: "Jon@org.com", casa_org: organization)
    admin3 = create(:casa_admin, email: "Bon@org.com", casa_org: organization)
    different_org_admin = create(:casa_admin, email: "Jovi@something.else", casa_org: create(:casa_org))
    supervisor = create(:supervisor, email: "super@visor.com", casa_org: organization)
    volunteer = create(:volunteer, email: "volun@tear.com", casa_org: organization)

    sign_in admin
    visit root_path

    within "#admins" do
      expect(page).to have_content(admin2.email)
      expect(page).to have_content(admin3.email)
      expect(page).to have_no_content(different_org_admin.email)
      expect(page).to have_no_content(supervisor.email)
      expect(page).to have_no_content(volunteer.email)
    end
  end
end

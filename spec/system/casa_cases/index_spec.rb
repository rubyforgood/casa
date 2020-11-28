require "rails_helper"

RSpec.describe "casa_cases/index", type: :system do
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
end

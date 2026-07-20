require "rails_helper"

RSpec.describe "casa_cases/index", type: :system do
  let(:organization) { create(:casa_org) }
  let(:volunteer) { create(:volunteer, display_name: "Bob Loblaw", casa_org: organization) }
  let(:case_number) { "CINA-1" }

  it "is filterable and linkable", :js do
    organization = build(:casa_org)
    admin = build(:casa_admin, casa_org: organization)
    volunteer = build(:volunteer, display_name: "Cool Volunteer", casa_org: organization)
    cina = build(:casa_case, active: true, casa_org: organization, case_number: case_number)
    tpr = create(:casa_case, active: true, casa_org: organization, case_number: "TPR-100")
    no_prefix = create(:casa_case, active: true, casa_org: organization, case_number: "123-12-123")
    create(:case_assignment, volunteer: volunteer, casa_case: cina)

    sign_in admin
    visit casa_cases_path

    expect(page).to have_link("Cool Volunteer", href: "/volunteers/#{volunteer.id}/edit")
    expect(page).to have_link("CINA-1", href: "/casa_cases/#{cina.case_number.parameterize}")
    expect(page).to have_link("TPR-100", href: "/casa_cases/#{tpr.case_number.parameterize}")
    expect(page).to have_link("123-12-123", href: "/casa_cases/#{no_prefix.case_number.parameterize}")

    # filters are server-side selects now
    expect(page).to have_select("Status")
    expect(page).to have_select("Case number prefix")
  end

end

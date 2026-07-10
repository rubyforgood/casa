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

    # each filter is a dropdown popover; open then close it so the open panel
    # doesn't intercept the click on the next (possibly wrapped) filter button
    [
      "Status",
      "Assigned to Volunteer",
      "Assigned to more than 1 Volunteer",
      "Assigned to Transition Aged Youth",
      "Casa Case Prefix"
    ].each do |filter|
      click_on filter
      click_on filter
    end
  end

  it "has a usable dropdown in sidebar" do
    cina = build(:casa_case, active: true, casa_org: organization, case_number: case_number)
    create(:case_assignment, volunteer: volunteer, casa_case: cina)

    sign_in volunteer

    visit root_path
    click_on "My Cases"
    within "#ddmenu_my-cases" do
      click_on case_number
    end

    expect(page).to have_text("CASA Case Details")
    expect(page).to have_text("Case number: CINA-1")
  end
end

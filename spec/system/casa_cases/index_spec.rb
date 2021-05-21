require "rails_helper"

RSpec.describe "casa_cases/index", :disable_bullet, type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:volunteer) { create(:volunteer, display_name: "Cool Volunteer", casa_org: organization) }
  let(:cina) { create(:casa_case, active: true, casa_org: organization, case_number: "CINA-1") }
  let!(:tpr) { create(:casa_case, active: true, casa_org: organization, case_number: "TPR-100") }
  let!(:no_prefix) { create(:casa_case, active: true, casa_org: organization, case_number: "123-12-123") }
  let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: cina) }

  scenario "filterable and linkable", :js do
    sign_in admin
    visit casa_cases_path

    expect(page).to have_link("Cool Volunteer", href: "/volunteers/#{volunteer.id}/edit")
    expect(page).to have_link("CINA-1", href: "/casa_cases/#{cina.id}")
    expect(page).to have_link("TPR-100", href: "/casa_cases/#{tpr.id}")
    expect(page).to have_link("123-12-123", href: "/casa_cases/#{no_prefix.id}")

    click_on "Status"
    click_on "Assigned to Volunteer"
    click_on "Assigned to more than 1 Volunteer"
    click_on "Assigned to Transition Aged Youth"
    click_on "Casa Case Prefix"
  end
end

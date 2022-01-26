require "rails_helper"

RSpec.describe "emancipations/show", type: :system do
  it "has a download emancipation checklist button" do
    org = create(:casa_org)
    casa_case = create(:casa_case, :transition_aged, casa_org: org)
    volunteer = create(:volunteer, casa_org: org)
    create(:case_assignment, casa_case: casa_case, volunteer: volunteer, active: true)

    sign_in volunteer
    visit casa_case_emancipation_path(casa_case)

    expect(page).to have_link "Download Checklist", href: casa_case_emancipation_path(casa_case, format: :docx)
  end
end

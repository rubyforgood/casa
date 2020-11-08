require "rails_helper"

RSpec.describe "volunteer edits case", type: :system do
  let(:volunteer) { create(:volunteer) }
  let(:casa_case) { create(:casa_case, casa_org: volunteer.casa_org) }
  let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }

  before do
    sign_in volunteer
  end

  it "clicks back button after editing case" do
    visit edit_casa_case_path(casa_case)

    expect(page).to_not have_select("Hearing type")
    expect(page).to_not have_select("Judge")

    select "Submitted", from: "casa_case_court_report_status"
    click_on "Update CASA Case"

    click_on "Back"

    expect(page).to have_text("My Case")
  end

  it "edits case" do
    visit casa_case_path(casa_case)
    expect(page).to have_text("Court Report Status: Not submitted")
    visit edit_casa_case_path(casa_case)
    select "Submitted", from: "casa_case_court_report_status"
    click_on "Update CASA Case"

    expect(page).to have_text("Court Date")
    expect(page).to have_text("Court Report Due Date")
    expect(page).not_to have_text("Day")
    expect(page).not_to have_text("Month")
    expect(page).not_to have_text("Year")
    expect(page).not_to have_text("Deactivate Case")

    visit casa_case_path(casa_case)
    expect(page).to have_text("Court Report Status: Submitted")
  end
end

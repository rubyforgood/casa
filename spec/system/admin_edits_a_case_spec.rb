require "rails_helper"

RSpec.describe "admin edits case", type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }
  let!(:judge) { create(:judge, casa_org: organization) }
  let(:contact_type_group) { create(:contact_type_group, casa_org: organization) }
  let!(:school) { create(:contact_type, name: "School", contact_type_group: contact_type_group) }
  let!(:therapist) { create(:contact_type, name: "Therapist", contact_type_group: contact_type_group) }

  before do
    sign_in admin
  end

  it "clicks back button after editing case" do
    visit edit_casa_case_path(casa_case)
    select "Submitted", from: "casa_case_court_report_status"
    click_on "Back"
    visit edit_casa_case_path(casa_case)
    expect(casa_case).not_to be_court_report_submitted
  end

  it "edits case" do
    visit casa_case_path(casa_case.id)
    click_on "Edit Case Details"
    expect(page).to have_select("Hearing type")
    expect(page).to have_select("Judge")
    select "Submitted", from: "casa_case_court_report_status"
    click_on "Update CASA Case"
    expect(page).to have_text("Submitted")
    expect(page).to have_text("Court Date")
    expect(page).to have_text("Court Report Due Date")
    expect(page).to have_text("Day")
    expect(page).to have_text("Month")
    expect(page).to have_text("Year")
    expect(page).not_to have_text("Deactivate Case")
  end

  it "deactivates a case" do
    visit edit_casa_case_path(casa_case)

    click_on "Deactivate CASA Case"
    sleep 10
    click_on "Yes, deactivate"
    expect(page).to have_text("Case #{casa_case.case_number} has been deactivated")
    expect(page).to have_text("Case was deactivated on: #{casa_case.updated_at.strftime("%m-%d-%Y")}")
    expect(page).to have_text("Reactivate CASA Case")
    expect(page).to_not have_text("Court Date")
    expect(page).to_not have_text("Court Report Due Date")
    expect(page).to_not have_text("Day")
    expect(page).to_not have_text("Month")
    expect(page).to_not have_text("Year")
  end

  it "reactivates a case" do
    visit edit_casa_case_path(casa_case)
    click_on "Deactivate CASA Case"
    sleep 10
    click_on "Yes, deactivate"
    click_on "Reactivate CASA Case"

    expect(page).to have_text("Case #{casa_case.case_number} has been reactivated.")
    expect(page).to have_text("Deactivate CASA Case")
    expect(page).to have_text("Court Date")
    expect(page).to have_text("Court Report Due Date")
    expect(page).to have_text("Day")
    expect(page).to have_text("Month")
    expect(page).to have_text("Year")
  end
end

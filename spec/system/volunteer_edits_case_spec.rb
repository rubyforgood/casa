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

    check "Court report submitted"
    click_on "Update CASA Case"

    has_no_checked_field? :court_report_submitted

    click_on "Back"

    expect(page).to have_text("My Case")
  end

  it "edits case" do
    visit casa_case_path(casa_case)
    expect(page).to have_text("Court Report Submission: Not Submitted")
    visit edit_casa_case_path(casa_case)
    has_no_checked_field? :court_report_submitted
    check "Court report submitted"
    click_on "Update CASA Case"
    has_checked_field? :court_report_submitted

    expect(page).to have_text("Court Date")
    expect(page).to have_text("Court Report Due Date")
    expect(page).not_to have_text("Day")
    expect(page).not_to have_text("Month")
    expect(page).not_to have_text("Year")
    expect(page).not_to have_text("Deactivate Case")

    visit casa_case_path(casa_case)
    expect(page).to have_text("Court Report Submission: Submitted")
  end
end

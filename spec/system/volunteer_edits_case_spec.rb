require "rails_helper"

RSpec.describe "volunteer edits case", type: :system do
  let(:volunteer) { create(:volunteer) }
  let(:casa_case) { create(:casa_case, casa_org: volunteer.casa_org) }
  let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }

  before do
    sign_in volunteer
    visit edit_casa_case_path(casa_case)
  end

  it "clicks back button after editing case" do
    check "Transition aged youth"
    click_on "Update CASA Case"

    has_checked_field? :transition_aged_youth

    click_on "Back"

    expect(page).to have_text("My Case")
  end

  it "edits case" do
    has_no_checked_field? :transition_aged_youth
    has_no_checked_field? :court_report_submitted
    check "Transition aged youth"
    check "Court report submitted"
    click_on "Update CASA Case"
    has_checked_field? :transition_aged_youth
    has_checked_field? :court_report_submitted
  end
end

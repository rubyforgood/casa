require "rails_helper"

RSpec.describe "admin edits case", type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }
  let(:contact_type_group) { create(:contact_type_group, casa_org: organization) }
  let!(:school) { create(:contact_type, name: "School", contact_type_group: contact_type_group) }
  let!(:therapist) { create(:contact_type, name: "Therapist", contact_type_group: contact_type_group) }

  before do
    sign_in admin
  end

  it "clicks back button after editing case" do
    visit edit_casa_case_path(casa_case)
    check "Court report submitted"
    has_checked_field? :court_report_submitted
    click_on "Back"
    visit edit_casa_case_path(casa_case)

    has_no_checked_field? :court_report_submitted
  end

  it "edits case" do
    visit casa_case_path(casa_case.id)
    click_on "Edit Case Details"
    has_no_checked_field? :court_report_submitted
    check "Court report submitted"
    click_on "Update CASA Case"

    has_checked_field? :court_report_submitted
    expect(page).to have_text("Court Date")
    expect(page).to have_text("Court Report Due Date")
    expect(page).to have_text("Day")
    expect(page).to have_text("Month")
    expect(page).to have_text("Year")
    expect(page).not_to have_text("Deactivate Case")
  end

  it "views deactivated case" do
    casa_case.deactivate
    visit edit_casa_case_path(casa_case)

    expect(page).to have_text("This case has been inactivated by a supervisor.")
    expect(page).not_to have_text("Court Date")
    expect(page).not_to have_text("Court Report Due Date")
    expect(page).not_to have_text("Day")
    expect(page).not_to have_text("Month")
    expect(page).not_to have_text("Year")
    expect(page).not_to have_text("Reactivate Case")
    expect(page).not_to have_text("Update Casa Case")
  end
end

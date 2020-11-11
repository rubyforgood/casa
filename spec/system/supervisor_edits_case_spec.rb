require "rails_helper"

RSpec.describe "supervisor edits case", type: :system do
  let(:casa_org) { create(:casa_org) }
  let(:supervisor) { create(:supervisor, casa_org: casa_org) }
  let(:casa_case) { create(:casa_case, casa_org: casa_org) }
  let!(:contact_type_group) { create(:contact_type_group, casa_org: casa_org) }
  let!(:contact_type_1) { create(:contact_type, name: "Youth", contact_type_group: contact_type_group) }
  let!(:contact_type_2) { create(:contact_type, name: "Supervisor", contact_type_group: contact_type_group) }
  let!(:next_year) { (Date.today.year + 1).to_s }

  before do
    sign_in supervisor
  end

  it "edits case" do
    visit casa_case_path(casa_case)
    expect(page).to have_text("Court Report Status: Not submitted")
    visit edit_casa_case_path(casa_case)
    select "Submitted", from: "casa_case_court_report_status"
    check "Youth"
    select "4", from: "casa_case_court_date_3i"
    select "November", from: "casa_case_court_date_2i"
    select next_year, from: "casa_case_court_date_1i"

    select "8", from: "casa_case_court_report_due_date_3i"
    select "September", from: "casa_case_court_report_due_date_2i"
    select next_year, from: "casa_case_court_report_due_date_1i"

    click_on "Update CASA Case"
    has_checked_field? "Youth"
    has_no_checked_field? "Supervisor"

    expect(page).to have_text("Court Date")
    expect(page).to have_text("Court Report Due Date")
    expect(page).to have_text("Day")
    expect(page).to have_text("Month")
    expect(page).to have_text("Year")
    expect(page).to have_text("November")
    expect(page).to have_text("September")

    visit casa_case_path(casa_case)

    expect(page).to have_text("Court Report Status: Submitted")
    expect(page).to have_text("4-NOV-#{next_year}")
    expect(page).to have_text("8-SEP-#{next_year}")
  end

  it "will return error message if date fields are not fully selected" do
    visit casa_case_path(casa_case)
    expect(page).to have_text("Court Report Status: Not submitted")
    visit edit_casa_case_path(casa_case)

    select "November", from: "casa_case_court_date_2i"
    select "April", from: "casa_case_court_report_due_date_2i"

    click_on "Update CASA Case"

    expect(page).to have_text("Court date was not a valid date.")
    expect(page).to have_text("Court report due date was not a valid date.")
  end

  it "will return error message if date fields are not valid" do
    visit casa_case_path(casa_case)
    expect(page).to have_text("Court Report Status: Not submitted")
    visit edit_casa_case_path(casa_case)

    select "31", from: "casa_case_court_date_3i"
    select "April", from: "casa_case_court_date_2i"
    select next_year, from: "casa_case_court_date_1i"

    select "31", from: "casa_case_court_report_due_date_3i"
    select "April", from: "casa_case_court_report_due_date_2i"
    select next_year, from: "casa_case_court_report_due_date_1i"

    click_on "Update CASA Case"

    expect(page).to have_text("Court date was not a valid date.")
    expect(page).to have_text("Court report due date was not a valid date.")
  end

  it "views deactivated case" do
    casa_case.deactivate
    visit edit_casa_case_path(casa_case)

    expect(page).to have_text("Case was deactivated on: #{casa_case.updated_at.strftime("%m-%d-%Y")}")
    expect(page).not_to have_text("Court Date")
    expect(page).not_to have_text("Court Report Due Date")
    expect(page).not_to have_text("Day")
    expect(page).not_to have_text("Month")
    expect(page).not_to have_text("Year")
    expect(page).not_to have_text("Reactivate Case")
    expect(page).not_to have_text("Update Casa Case")
  end

  context "When a Casa instance has no judge names added" do
    it "does not display judge names details" do
      casa_case = create(:casa_case, casa_org: casa_org, judge: nil)

      visit edit_casa_case_path(casa_case)

      expect(page).not_to have_select("Judge")
    end
  end

  context "When an admin has added judge names to a Casa instance" do
    it "displays judge details as select option" do
      create :judge, casa_org: casa_org

      visit edit_casa_case_path(casa_case)

      expect(page).to have_select("Judge")
    end
  end
end

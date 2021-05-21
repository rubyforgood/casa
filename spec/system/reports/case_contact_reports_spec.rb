require "rails_helper"

RSpec.describe "case_contact_reports/index", :disable_bullet, type: :system do
  let(:admin) { create(:casa_admin) }

  it "filters report by date and selected contact type", js: true do
    sign_in admin

    contact_type_group = create(:contact_type_group)
    court = create(:contact_type, name: "Court", contact_type_group: contact_type_group)
    school = create(:contact_type, name: "School", contact_type_group: contact_type_group)

    contact1 = create(:case_contact, occurred_at: 20.days.ago, contact_types: [court], notes: "Case Contact 1")
    contact2 = create(:case_contact, occurred_at: 20.days.ago, contact_types: [court], notes: "Case Contact 2")
    contact3 = create(:case_contact, occurred_at: 20.days.ago, contact_types: [court, school], notes: "Case Contact 3")

    excluded_by_date = create(:case_contact, occurred_at: 40.days.ago, contact_types: [court], notes: "Excluded by date")
    excluded_by_contact_type = create(:case_contact, occurred_at: 20.days.ago, contact_types: [school], notes: "Excluded by Contact Type")

    visit reports_path
    fill_in "report_start_date", with: 30.days.ago.to_date.strftime("%m/%d/%Y")
    fill_in "report_end_date", with: 10.days.ago.to_date.strftime("%m/%d/%Y")
    select court.name, from: "report_contact_type_ids"
    click_button "Download Report"
    wait_for_download

    expect(download_content).to include(contact1.notes)
    expect(download_content).to include(contact2.notes)
    expect(download_content).to include(contact3.notes)

    expect(download_content).not_to include(excluded_by_date.notes)
    expect(download_content).not_to include(excluded_by_contact_type.notes)
  end

  it "filters report by contact type group", js: true do
    sign_in admin

    contact_type_group = create(:contact_type_group)
    court = create(:contact_type, name: "Court", contact_type_group: contact_type_group)
    contact1 = create(:case_contact, occurred_at: Date.yesterday, contact_types: [court], notes: "Case Contact 1")

    excluded_contact_type_group = create(:contact_type_group)
    school = create(:contact_type, name: "School", contact_type_group: excluded_contact_type_group)
    excluded_by_contact_type_group = create(:case_contact, occurred_at: Date.yesterday, contact_types: [school], notes: "Excluded by Contact Type")

    visit reports_path
    select contact_type_group.name, from: "report_contact_type_group_ids"
    click_button "Download Report"
    wait_for_download

    expect(download_content).to include(contact1.notes)
    expect(download_content).not_to include(excluded_by_contact_type_group.notes)
  end
end

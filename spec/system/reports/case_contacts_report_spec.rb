require "rails_helper"

RSpec.describe "/reports", type: :system do
  let(:admin) { create(:casa_admin) }

  setup { sign_in admin }

  describe "CSV report" do
    it "filters report by date and selected contact type", js: true do
      contact_type_group = create(:contact_type_group)
      court = create(:contact_type, name: "Court", contact_type_group: contact_type_group)
      school = create(:contact_type, name: "School", contact_type_group: contact_type_group)

      contact1 = create(:case_contact, occurred_at: 20.days.ago, contact_types: [court], notes: "Case Contact 1")
      contact2 = create(:case_contact, occurred_at: 20.days.ago, contact_types: [court], notes: "Case Contact 2")
      contact3 = create(:case_contact, occurred_at: 20.days.ago, contact_types: [court, school], notes: "Case Contact 3")

      excluded_by_date = create(:case_contact, occurred_at: 40.days.ago, contact_types: [court], notes: "Excluded by date")
      excluded_by_contact_type = create(:case_contact, occurred_at: 20.days.ago, contact_types: [school], notes: "Excluded by Contact Type")

      visit reports_path
      start_date = 30.days.ago.strftime(::DateHelper::RUBY_MONTH_DAY_YEAR_FORMAT)
      end_date = 10.days.ago.strftime(::DateHelper::RUBY_MONTH_DAY_YEAR_FORMAT)
      page.execute_script("document.getElementById('report_start_date').setAttribute('value', '#{start_date}')")
      page.execute_script("document.getElementById('report_end_date').setAttribute('value', '#{end_date}')")
      select court.name, from: "multiple-select-field3"
      click_button "Download Report"
      click_button "CSV"

      expect(download_content).to include(contact1.notes)
      expect(download_content).to include(contact2.notes)
      expect(download_content).to include(contact3.notes)

      expect(download_content).not_to include(excluded_by_date.notes)
      expect(download_content).not_to include(excluded_by_contact_type.notes)
    end

    it "filters report by contact type group", js: true do
      contact_type_group = create(:contact_type_group)
      court = create(:contact_type, name: "Court", contact_type_group: contact_type_group)
      contact1 = create(:case_contact, occurred_at: Date.yesterday, contact_types: [court], notes: "Case Contact 1")

      excluded_contact_type_group = create(:contact_type_group)
      school = create(:contact_type, name: "School", contact_type_group: excluded_contact_type_group)
      excluded_by_contact_type_group = create(:case_contact, occurred_at: Date.yesterday, contact_types: [school], notes: "Excluded by Contact Type")

      visit reports_path
      select contact_type_group.name, from: "multiple-select-field4"
      click_button "Download Report"
      click_button "CSV"

      expect(download_content).to include(contact1.notes)
      expect(download_content).not_to include(excluded_by_contact_type_group.notes)
    end
  end

  describe "Excel report" do
    it "downloads report in Excel format", js: true do
      contact_type_group = create(:contact_type_group)
      court = create(:contact_type, name: "Court", contact_type_group: contact_type_group)
      contact1 = create(:case_contact, occurred_at: Date.yesterday, contact_types: [court], notes: "Case Contact 1")

      visit reports_path
      select contact_type_group.name, from: "multiple-select-field4"
      click_button "Download Report"
      click_button "Excel"
      wait_for_download

      expect(download_file_name).to match(/.xlsx/)
      expect(download_file_name).not_to match(/.csv/)
      expect(download_xlsx.sheet("Case Contacts").row(2)).to include(contact1.notes)
    end

    it "can filter out columns", js: true do
      contact_type_group = create(:contact_type_group)
      court = create(:contact_type, name: "Court", contact_type_group: contact_type_group)
      contact1 = create(:case_contact, occurred_at: Date.yesterday, contact_types: [court], notes: "Case Contact 1")

      visit reports_path
      select contact_type_group.name, from: "multiple-select-field4"

      click_button "Filter Columns"
      uncheck "Case Contact Notes"
      page.evaluate_script("$('#filterColumns').hide()")
      page.evaluate_script("$('.modal-backdrop').hide()")
      sleep(1)

      click_button "Download Report"
      click_button "Excel"

      expect(download_xlsx.sheet("Case Contacts").row(2)).to include(contact1.notes)
    end
  end
end

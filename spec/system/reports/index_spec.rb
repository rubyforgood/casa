require "rails_helper"

VOLUNTEER_SELECT_ID = "multiple-select-field2"
SUPERVISOR_SELECT_ID = "multiple-select-field1"
CONTACT_TYPE_SELECT_ID = "multiple-select-field3"
CONTACT_TYPE_GROUP_SELECT_ID = "multiple-select-field4"

RSpec.describe "reports", :js, type: :system do
  shared_examples "downloads report button" do |button_name, feedback|
    it "downloads #{button_name.downcase}", :aggregate_failures do
      expect(page).to have_button(button_name)
      click_on button_name
      expect(page).to have_text(feedback)
    end
  end

  shared_examples "downloads case contacts report with filter" do |filter_name, setup_action, filter_action|
    it "downloads case contacts report with #{filter_name}" do
      instance_exec(&setup_action) if setup_action
      visit reports_path
      instance_exec(&filter_action)
      click_on "Download Report"
      expect(page).to have_text("Downloading Report")
    end
  end

  shared_examples "empty select downloads report" do |select_id, description|
    it "renders the #{description} select with no options and downloads the report" do
      expect(page).to have_select(select_id, options: [])
      click_on "Download Report"
      expect(page).to have_text("Downloading Report")
    end
  end

  context "with a volunteer user" do
    before do
      user = create(:volunteer)

      sign_in user
      visit reports_path

      expect(page).not_to have_text "Case Contacts Report"
      expect(page).to have_text "Sorry, you are not authorized to perform this action."
    end
  end

  context "supervisor user" do
    it "renders form elements", :js do
      user = create(:supervisor)

      sign_in user
      visit reports_path

      expect(page).to have_text "Case Contacts Report"
      expect(page).to have_field("report_start_date", with: 6.months.ago.strftime("%Y-%m-%d"))
      expect(page).to have_field("report_end_date", with: Date.today)
      expect(page).to have_text "Assigned To"
      expect(page).to have_text "Volunteers"
      expect(page).to have_text "Contact Type"
      expect(page).to have_text "Contact Type Group"
      expect(page).to have_text "Want Driving Reimbursement"
      expect(page).to have_text "Contact Made"
      expect(page).to have_text "Transition Aged Youth"
      expect(page).to have_field("Both", count: 3)
      expect(page).to have_field("Yes", count: 3)
      expect(page).to have_field("No", count: 3)
    end

    it "downloads report", :js do
      user = create(:supervisor)

      sign_in user
      visit reports_path

      click_on "Download Report"
      expect(page).to have_text("Downloading Report")
    end
  end

  context "casa_admin user" do
    it "renders form elements", :js do
      user = create(:casa_admin)

      sign_in user
      visit reports_path

      expect(page).to have_text "Case Contacts Report"
      expect(page).to have_field("report_start_date", with: 6.months.ago.strftime("%Y-%m-%d"))
      expect(page).to have_field("report_end_date", with: Date.today)
      expect(page).to have_text "Assigned To"
      expect(page).to have_text "Volunteers"
      expect(page).to have_text "Contact Type"
      expect(page).to have_text "Contact Type Group"
      expect(page).to have_text "Want Driving Reimbursement"
      expect(page).to have_text "Contact Made"
      expect(page).to have_text "Transition Aged Youth"
      expect(page).to have_field("Both", count: 3)
      expect(page).to have_field("Yes", count: 3)
      expect(page).to have_field("No", count: 3)
    end

    it "downloads report", :js do
      user = create(:casa_admin)

      sign_in user
      visit reports_path

      click_on "Download Report"
      expect(page).to have_text("Downloading Report")
    end
  end
end

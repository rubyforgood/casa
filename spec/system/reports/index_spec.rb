require "rails_helper"

RSpec.describe "reports", type: :system, js: true do
  context "volunteer user" do
    it "redirects to root" do
      user = create(:volunteer)

      sign_in user
      visit reports_path

      expect(page).to_not have_text "Case Contacts Report"
      expect(page).to have_text "Sorry, you are not authorized to perform this action."
    end
  end

  context "supervisor user" do
    it "renders form elements", js: true do
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

    it "downloads report", js: true do
      user = create(:supervisor)

      sign_in user
      visit reports_path

      click_on "Download Report"
      expect(page).to have_text("Downloading Report")
    end
  end

  context "casa_admin user" do
    it "renders form elements", js: true do
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

    it "downloads report", js: true do
      user = create(:casa_admin)

      sign_in user
      visit reports_path

      click_on "Download Report"
      expect(page).to have_text("Downloading Report")
    end
  end
end

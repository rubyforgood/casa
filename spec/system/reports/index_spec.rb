require "rails_helper"

RSpec.describe "reports", type: :system, js: true do
  context "volunteer user" do
    it "redirects to root" do
      user = create(:volunteer)

      sign_in user
      visit reports_path

      expect(page).to_not have_text I18n.t("reports.index.reports_subhead")
      expect(page).to have_text "Sorry, you are not authorized to perform this action."
    end
  end

  context "supervisor user" do
    it "renders form elements", js: true do
      user = create(:supervisor)

      sign_in user
      visit reports_path

      expect(page).to have_text I18n.t("reports.index.reports_subhead")
      expect(page).to have_text I18n.l(6.months.ago.to_date, format: :day_and_date, default: "")
      expect(page).to have_text I18n.l(Date.today.to_date, format: :day_and_date, default: "")
      expect(page).to have_text I18n.t("reports.index.assigned_to_label")
      expect(page).to have_text I18n.t("reports.index.volunteers_label")
      expect(page).to have_text I18n.t("reports.index.contact_type_label")
      expect(page).to have_text I18n.t("reports.index.contact_type_group_label")
      expect(page).to have_text I18n.t("reports.index.driving_reimbursement_label")
      expect(page).to have_text I18n.t("reports.index.contact_made_label")
      expect(page).to have_text I18n.t("reports.index.transition_aged_label")
      expect(page).to have_field(I18n.t("common.both_text"), count: 3)
      expect(page).to have_field(I18n.t("common.yes_text"), count: 3)
      expect(page).to have_field(I18n.t("common.no_text"), count: 3)
    end

    it "downloads report", js: true do
      user = create(:supervisor)

      sign_in user
      visit reports_path

      click_on I18n.t("reports.index.download_report_button")
      expect(page).to have_text("Downloading Report")
    end
  end

  context "casa_admin user" do
    it "renders form elements", js: true do
      user = create(:casa_admin)

      sign_in user
      visit reports_path

      expect(page).to have_text I18n.t("reports.index.reports_subhead")
      expect(page).to have_text I18n.l(6.months.ago.to_date, format: :day_and_date, default: "")
      expect(page).to have_text I18n.l(Date.today.to_date, format: :day_and_date, default: "")
      expect(page).to have_text I18n.t("reports.index.assigned_to_label")
      expect(page).to have_text I18n.t("reports.index.volunteers_label")
      expect(page).to have_text I18n.t("reports.index.contact_type_label")
      expect(page).to have_text I18n.t("reports.index.contact_type_group_label")
      expect(page).to have_text I18n.t("reports.index.driving_reimbursement_label")
      expect(page).to have_text I18n.t("reports.index.contact_made_label")
      expect(page).to have_text I18n.t("reports.index.transition_aged_label")
      expect(page).to have_field(I18n.t("common.both_text"), count: 3)
      expect(page).to have_field(I18n.t("common.yes_text"), count: 3)
      expect(page).to have_field(I18n.t("common.no_text"), count: 3)
    end

    it "downloads report", js: true do
      user = create(:casa_admin)

      sign_in user
      visit reports_path

      click_on I18n.t("reports.index.download_report_button")
      expect(page).to have_text("Downloading Report")
    end
  end
end

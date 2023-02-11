require "rails_helper"

RSpec.describe "reports", type: :system, js: true do
  let!(:admin) { build(:casa_admin) }
  let!(:case_contact) { build(:case_contact) }

  before do
    sign_in user
    visit reports_path
  end

  context "volunteer user" do
    let(:user) { create(:volunteer) }

    it "redirects to root" do
      expect(page).to_not have_text I18n.t("reports.index.reports_subhead")
      expect(page).to have_text "Sorry, you are not authorized to perform this action."
    end
  end

  shared_examples "can view page" do
    it "renders form elements", js: true do
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
      click_on I18n.t("reports.index.download_report_button")
      expect(page).to have_text("Downloading Report")
    end

    it "downloads milesage report", js: true do
      expect(page).to have_button I18n.t("reports.index.download_mileage_report_button.enabled")

      click_on I18n.t("reports.index.download_mileage_report_button.enabled")

      sleep 1

      expect(page).to have_button I18n.t("reports.index.download_mileage_report_button.disabled"), disabled: true

      sleep 3

      expect(page).to have_button I18n.t("reports.index.download_mileage_report_button.enabled")
    end
  end

  context "supervisor user" do
    it_behaves_like "can view page" do
      let(:user) { create(:supervisor) }
    end
  end

  context "casa_admin user" do
    it_behaves_like "can view page" do
      let(:user) { create(:casa_admin) }
    end
  end
end

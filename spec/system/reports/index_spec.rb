require "rails_helper"

RSpec.describe "reports", type: :system do
  let!(:admin) { build(:casa_admin) }
  let!(:case_contact) { build(:case_contact) }

  before do
    sign_in user
    visit reports_path
  end

  context "volunteer user" do
    let(:user) { build(:volunteer) }

    it "redirects to root" do
      expect(page).to_not have_text I18n.t("reports.index.reports_subhead")
      expect(page).to have_text "not authorized"
    end
  end

  shared_examples "can view page" do
    it "renders form elements", js: true do
      expect(page).to have_text I18n.t("reports.index.reports_subhead")
      expect(page).to have_field("report_start_date", with: 6.months.ago.to_date)
      expect(page).to have_field("report_end_date", with: Date.today.to_date)
      expect(page).to have_text I18n.t("reports.index.assigned_to_label")
      expect(page.find("input[placeholder=\'#{I18n.t("reports.index.select_contact_types_placeholder")}\']")).to be_present
      expect(page).to have_text I18n.t("reports.index.volunteers_label")
      expect(page.find("input[placeholder=\'#{I18n.t("reports.index.select_volunteers_placeholder")}\']")).to be_present
      expect(page).to have_text I18n.t("reports.index.contact_type_label")
      expect(page.find("input[placeholder=\'#{I18n.t("reports.index.select_contact_types_placeholder")}\']")).to be_present
      expect(page).to have_text I18n.t("reports.index.contact_type_group_label")
      expect(page.find("input[placeholder=\'#{I18n.t("reports.index.select_contact_type_groups_placeholder")}\']")).to be_present
      expect(page).to have_text I18n.t("reports.index.driving_reimbursement_label")
      expect(page).to have_text I18n.t("reports.index.contact_made_label")
      expect(page).to have_field(I18n.t("common.both_text"), count: 2)
      expect(page).to have_field(I18n.t("common.yes_text"), count: 2)
      expect(page).to have_field(I18n.t("common.no_text"), count: 2)
    end

    it "downloads report", js: true do
      click_on I18n.t("reports.index.download_report_button")
      expect(page).to have_button I18n.t("reports.index.download_report_button")
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

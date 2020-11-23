require "rails_helper"

RSpec.describe "reports/index", type: :system do
  let!(:admin) { create(:casa_admin) }
  let!(:case_contact) { create(:case_contact) }

  before do
    sign_in user
    visit reports_path
  end

  context "when volunteer" do
    let(:user) { create(:volunteer) }

    it "redirects to root" do
      expect(page).to_not have_text "Case Contacts Report"
      expect(page).to have_text "not authorized"
    end
  end

  shared_examples "can view page" do
    it "downloads report" do
      expect(page).to have_text("Case Contacts Report") &
        have_field("report_start_date", with: 6.months.ago.to_date) &
        have_field("report_end_date", with: Date.today.to_date)
      click_on "Download Report"
      expect(page).to have_button "Download Report"
    end
  end

  context "when supervisor" do
    it_behaves_like "can view page" do
      let(:user) { create(:supervisor) }
    end
  end

  context "when casa_admin" do
    it_behaves_like "can view page" do
      let(:user) { create(:casa_admin) }
    end
  end
end

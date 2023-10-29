require "rails_helper"

RSpec.describe "/reports", type: :system do
  let(:admin) { create(:casa_admin) }

  it "downloads mileage report", js: true do
    sign_in admin

    supervisor = create(:supervisor)
    volunteer = create(:volunteer, supervisor: supervisor)
    case_contact_with_mileage = create(:case_contact, want_driving_reimbursement: true, miles_driven: 10, creator: volunteer)
    case_contact_without_mileage = create(:case_contact)

    visit reports_path
    click_button "Mileage Report"
    wait_for_download

    expect(download_file_name).to match(/mileage-report-\d{4}-\d{2}-\d{2}.csv/)
    expect(download_content).to include(case_contact_with_mileage.creator.display_name)
    expect(download_content).to include(case_contact_with_mileage.creator.supervisor.display_name)
    expect(download_content).not_to include(case_contact_without_mileage.creator.display_name)
  end

  it "downloads missing data report", js: true do
    sign_in admin

    visit reports_path
    click_button "Missing Data Report"
    wait_for_download

    expect(download_file_name).to match(/missing-data-report-\d{4}-\d{2}-\d{2}.csv/)
  end

  it "downloads learning hours report", js: true do
    sign_in admin

    visit reports_path
    click_button "Learning Hours Report"
    wait_for_download

    expect(download_file_name).to match(/learning-hours-report-\d{4}-\d{2}-\d{2}.csv/)
  end

  it "downloads followup report", js: true do
    sign_in admin

    visit reports_path
    click_button "Followups Report"
    wait_for_download

    expect(download_file_name).to match(/followup-report-\d{4}-\d{2}-\d{2}.csv/)
  end

  context "as volunteer" do
    let(:volunteer) { create(:volunteer) }

    it "cannot accesses reports page" do
      sign_in volunteer

      visit reports_path
      expect(current_path).to eq(casa_cases_path)
      expect(page).to have_text "Sorry, you are not authorized to perform this action."
    end

    it "cannot download followup report" do
      sign_in volunteer

      visit followup_reports_path
      expect(current_path).to eq(casa_cases_path)
      expect(page).to have_text "Sorry, you are not authorized to perform this action."
    end
  end
end

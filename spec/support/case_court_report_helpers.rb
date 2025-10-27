# Helper methods for case court reports system specs
module CaseCourtReportHelpers
  def open_generate_modal
    visit case_court_reports_path
    find('[data-bs-target="#generate-docx-report-modal"]').click
    expect(page).to have_selector("#generate-docx-report-modal", visible: :visible)
  end

  def open_native_case_select
    open_generate_modal
    expect(page).to have_selector("#case-selection", visible: :visible)
  end

  def open_select2_dropdown
    open_generate_modal
    expect(page).to have_css("#case_select_body .selection", visible: :visible)
    find("#case_select_body .selection").click
    expect(page).to have_css(".select2-dropdown", visible: :visible)
  end
end

RSpec.configure do |config|
  config.include CaseCourtReportHelpers, type: :system
end

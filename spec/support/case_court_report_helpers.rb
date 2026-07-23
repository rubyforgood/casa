# frozen_string_literal: true

# Helper methods for case court reports system specs (casa_app: Dialog + TomSelect).
module CaseCourtReportHelpers
  # Clicks the "Download court report as a .docx" trigger and confirms the dialog is open.
  def open_court_report_modal
    click_on "Download court report as a .docx"
    expect(page).to have_selector("#generate-docx-report-modal", visible: :visible)
  end

  # Opens the TomSelect dropdown for the case picker inside the (open) modal.
  def open_case_select_dropdown
    within "#generate-docx-report-modal" do
      find(".ts-control").click
    end
    expect(page).to have_css(".ts-dropdown", visible: :visible)
  end
end

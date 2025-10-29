# frozen_string_literal: true

# Helper methods for case court reports system specs
module CaseCourtReportHelpers
  # Finds the 'Generate Report' button, clicks it, and confirms the modal is visible.
  # Assumes the user is already on the case_court_reports_path.
  def open_court_report_modal
    find('[data-bs-target="#generate-docx-report-modal"]').click
    expect(page).to have_selector("#generate-docx-report-modal", visible: :visible)
  end

  # Opens the Select2 dropdown within the (already open) report modal.
  # Confirms the dropdown options are visible.
  def open_case_select2_dropdown
    # Wait for the Select2 container to be visible
    expect(page).to have_css("#case_select_body .selection", visible: :visible)

    # Click the container to open the dropdown
    find("#case_select_body .selection").click

    # Wait for the dropdown to appear
    expect(page).to have_css(".select2-dropdown", visible: :visible)
  end

  # Polls the database until the casa_case has an ActiveStorage court_report attached.
  # This is used after clicking 'Generate Report' to wait for the background job to complete.
  def wait_for_report_attachment(casa_case, timeout: 5)
    casa_case.reload # Ensure we have the latest record

    Timeout.timeout(timeout) do
      until casa_case.court_reports.attached?
        sleep 0.2
        casa_case.reload
      end
    end
  end
end

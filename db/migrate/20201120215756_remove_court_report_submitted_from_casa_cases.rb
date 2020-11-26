class RemoveCourtReportSubmittedFromCasaCases < ActiveRecord::Migration[6.0]
  def change
    remove_column :casa_cases, :court_report_submitted, :boolean
  end
end

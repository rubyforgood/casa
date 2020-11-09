class AddCourtReportStatusToCasaCases < ActiveRecord::Migration[6.0]
  def change
    add_column :casa_cases, :court_report_submitted_at, :datetime
    add_column :casa_cases, :court_report_status, :integer, default: 0, not_null: true
  end
end

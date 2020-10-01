class AddCourtReportSubmittedToCasaCases < ActiveRecord::Migration[6.0]
  def change
    add_column :casa_cases, :court_report_submitted, :boolean, default: false, null: false
  end
end

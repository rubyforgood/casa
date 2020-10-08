class AddCourtReportDueDateToCasaCases < ActiveRecord::Migration[6.0]
  def change
    add_column :casa_cases, :court_report_due_date, :datetime
  end
end

class AddCourtReportDueDateToCourtDates < ActiveRecord::Migration[7.0]
  def change
    add_column :court_dates, :court_report_due_date, :datetime, precision: nil
  end
end

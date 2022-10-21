class RemoveCourtReportDueDateFromCasaCases < ActiveRecord::Migration[7.0]
  def up
    safety_assured { remove_column :casa_cases, :court_report_due_date }
  end

  def down
    add_column :casa_cases, :court_report_due_date, :datetime
  end
end

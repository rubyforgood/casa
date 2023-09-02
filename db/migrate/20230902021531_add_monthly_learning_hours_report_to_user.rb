class AddMonthlyLearningHoursReportToUser < ActiveRecord::Migration[7.0]
  def change
    # in your migration
    add_column :users, :monthly_learning_hours_report, :boolean, default: false
  end
end

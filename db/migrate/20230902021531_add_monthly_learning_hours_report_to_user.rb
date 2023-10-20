class AddMonthlyLearningHoursReportToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :monthly_learning_hours_report, :boolean, default: false, null: false
  end
end

class AddDurationHoursToLearningHour < ActiveRecord::Migration[6.1]
  def change
    add_column :learning_hours, :duration_hours, :integer, null: false
  end
end

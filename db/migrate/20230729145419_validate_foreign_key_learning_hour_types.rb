class ValidateForeignKeyLearningHourTypes < ActiveRecord::Migration[7.0]
  def change
    validate_foreign_key :learning_hours, :learning_hour_types
  end
end

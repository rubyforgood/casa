class AddForeignKeyLearningHourTypes < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :learning_hours, :learning_hour_types, validate: false
  end
end

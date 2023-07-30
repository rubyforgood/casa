class RemoveLearningType < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :learning_hours, :learning_type, :integer, default: 5, not_null: true}
  end
end

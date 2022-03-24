class AddNameToLearningHour < ActiveRecord::Migration[6.1]
  def change
    add_column :learning_hours, :name, :string
  end
end

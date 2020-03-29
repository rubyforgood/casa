class AddDurationAndDateToCaseUpdate < ActiveRecord::Migration[6.0]
  def change
    add_column :case_updates, :duration_minutes, :integer, null: false
    add_column :case_updates, :occurred_at, :datetime, null: false
  end
end

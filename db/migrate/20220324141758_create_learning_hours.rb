class CreateLearningHours < ActiveRecord::Migration[6.1]
  def change
    create_table :learning_hours do |t|
      t.integer :duration_minutes, null: false
      t.datetime :occurred_at, null: false
      t.references :user, null: false, foreign_key: true
      t.integer :learning_type, default: 5, not_null: true

      t.timestamps
    end
  end
end

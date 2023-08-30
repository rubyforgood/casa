class CreateLearningHourTopics < ActiveRecord::Migration[7.0]
  def change
    create_table :learning_hour_topics do |t|
      t.string :name, null: false
      t.references :casa_org, null: false, foreign_key: true
      t.integer :position, default: 1

      t.timestamps
    end
  end
end

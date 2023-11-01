class CreateLearningHourTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :learning_hour_types do |t|
      t.references :casa_org, null: false, foreign_key: true
      t.string :name
      t.boolean :active, default: true
      t.integer :position, default: 1

      t.timestamps
    end
  end
end

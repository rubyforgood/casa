class CreateOtherDuty < ActiveRecord::Migration[6.1]
  def change
    create_table :other_duties do |t|
      t.bigint :creator_id, null: false
      t.string :creator_type
      t.datetime :occurred_at
      t.bigint :duration_minutes
      t.text :notes

      t.timestamps
    end
  end
end

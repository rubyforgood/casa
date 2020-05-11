class CreateCaseContacts < ActiveRecord::Migration[6.0]
  def change
    create_table :case_contacts do |t|
      t.references :creator, foreign_key: {to_table: :users}, null: false
      t.references :casa_case, null: false, foreign_key: true
      t.string :contact_type, null: false
      t.string :other_type_text, null: true
      t.integer :duration_minutes, null: false
      t.datetime :occurred_at, null: false

      t.timestamps
    end
  end
end

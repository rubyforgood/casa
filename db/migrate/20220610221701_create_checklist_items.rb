class CreateChecklistItems < ActiveRecord::Migration[7.0]
  def change
    create_table :checklist_items do |t|
      t.integer :hearing_type_id
      t.text :description, null: false
      t.string :category, null: false
      t.boolean :mandatory, default: false, null: false
      t.timestamps
    end
    add_index :checklist_items, :hearing_type_id
  end
end

class CreatePatchNoteGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :patch_note_groups do |t|
      t.string :value, null: false
      t.index :value, unique: true

      t.timestamps
    end
  end
end

class CreatePatchNotes < ActiveRecord::Migration[7.0]
  def change
    create_table :patch_notes do |t|
      t.text :note, null: false
      t.references :patch_note_type, null: false, foreign_key: true
      t.references :patch_note_group, null: false, foreign_key: true

      t.timestamps
    end
  end
end

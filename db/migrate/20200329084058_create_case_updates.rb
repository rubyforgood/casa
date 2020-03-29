class CreateCaseUpdates < ActiveRecord::Migration[6.0]
  def change
    create_table :case_updates do |t|
      t.references :user, null: false, foreign_key: true
      t.references :casa_case, null: false, foreign_key: true
      t.string :update_type, null: false
      t.string :other_type_text, null: true

      t.timestamps
    end
  end
end

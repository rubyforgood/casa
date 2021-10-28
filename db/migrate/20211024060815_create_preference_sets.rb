class CreatePreferenceSets < ActiveRecord::Migration[6.1]
  def change
    create_table :preference_sets do |t|
      t.references :user, index: true, foreign_key: true
      t.jsonb :case_volunteer_columns, null: false, default: "{}"

      t.timestamps
    end
  end
end

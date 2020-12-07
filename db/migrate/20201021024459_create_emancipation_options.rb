class CreateEmancipationOptions < ActiveRecord::Migration[6.0]
  def change
    create_table :emancipation_options do |t|
      t.references :emancipation_category, null: false, foreign_key: true
      t.string :name, null: false
      t.index [:emancipation_category_id, :name], unique: true
      t.timestamps
    end
  end
end

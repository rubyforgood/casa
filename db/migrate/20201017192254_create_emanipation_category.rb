class CreateEmanipationCategory < ActiveRecord::Migration[6.0]
  def change
    create_table :emancipation_categories do |t|
      t.string :name, null: false, index: { unique: true }
      t.boolean :mutually_exclusive
    end
  end
end

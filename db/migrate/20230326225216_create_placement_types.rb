class CreatePlacementTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :placement_types do |t|
      t.string :name, null: false
      t.references :casa_org, null: false, foreign_key: true
      t.timestamps
    end
  end
end

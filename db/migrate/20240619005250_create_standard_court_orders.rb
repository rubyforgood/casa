class CreateStandardCourtOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :standard_court_orders do |t|
      t.string :value
      t.references :casa_org, null: false, foreign_key: true

      t.timestamps
    end

    add_index :standard_court_orders, [:casa_org_id, :value], unique: true
  end
end

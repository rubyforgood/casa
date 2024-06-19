class CreateStandardCourtOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :standard_court_orders do |t|
      t.string :value
      t.references :casa_org, null: false, foreign_key: true

      t.timestamps
    end
  end
end

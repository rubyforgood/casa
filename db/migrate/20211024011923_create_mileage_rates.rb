class CreateMileageRates < ActiveRecord::Migration[6.1]
  def change
    create_table :mileage_rates do |t|
      t.decimal :amount
      t.date :effective_date
      t.boolean :is_active, default: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

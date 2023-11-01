class AddForeignKeyConstraintsToMileageRates < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :mileage_rates, :casa_orgs, column: :casa_org_id, validate: false
  end
end

class AddCasaOrgToMileageRate < ActiveRecord::Migration[6.1]
  def change
    # null false is dangerous if there are any in the db already! There aren't tho
    add_column :mileage_rates, :casa_org_id, :bigint, null: false
    add_index :mileage_rates, :casa_org_id
  end
end

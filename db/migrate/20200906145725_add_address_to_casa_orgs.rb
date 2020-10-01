class AddAddressToCasaOrgs < ActiveRecord::Migration[6.0]
  def change
    add_column :casa_orgs, :address, :string
  end
end

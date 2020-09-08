class AddDisplayNameToCasaOrgs < ActiveRecord::Migration[6.0]
  def change
    add_column :casa_orgs, :display_name, :string
  end
end

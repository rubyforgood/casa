class AddAdditionalExpensesToCasaOrgs < ActiveRecord::Migration[7.0]
  def change
    add_column :casa_orgs, :additional_expenses_enabled, :boolean, default: false
  end
end

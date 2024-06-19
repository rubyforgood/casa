class AddOtherDutiesEnabledToCasaOrg < ActiveRecord::Migration[7.1]
  def change
    add_column :casa_orgs, :other_duties_enabled, :boolean, default: true
  end
end

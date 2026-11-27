class AddTimeZoneToCasaOrgs < ActiveRecord::Migration[8.1]
  def change
    add_column :casa_orgs, :time_zone, :string, default: "America/New_York", null: false
  end
end

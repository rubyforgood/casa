class User < ApplicationRecord
  self.table_name = "users"
end

class AddTypeToUser < ActiveRecord::Migration[6.0]
  def up
    add_column :users, :type, :string
    add_column :users, :active, :boolean, default: true

    # Set supervisor
    User.where(role: "supervisor").update_all(type: "Supervisor")

    # Set volunteers
    User.where(role: "volunteer").update_all(type: "Volunteer")
    User.where(role: "inactive").update_all(type: "Volunteer", active: false)

    # Set casa_admins
    User.where(role: "casa_admin").update_all(type: "CasaAdmin")
  end

  def down
    drop_column :users, :type
  end
end

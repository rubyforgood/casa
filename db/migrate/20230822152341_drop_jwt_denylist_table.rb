class DropJwtDenylistTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :jwt_denylist, if_exists: true
  end
end

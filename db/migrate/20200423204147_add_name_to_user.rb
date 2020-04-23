class AddNameToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :display_name, :string, default: ""
  end
end

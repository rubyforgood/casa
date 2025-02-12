class RemoveTokenFromUsers < ActiveRecord::Migration[7.2]
  def change
    safety_assured { remove_column :users, :token, :string }
  end
end

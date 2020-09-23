class AddDeactivatedAccountAtToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :deactivated_account_at, :datetime
  end
end

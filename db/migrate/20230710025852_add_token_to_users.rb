class AddTokenToUsers < ActiveRecord::Migration[7.0]
  def up
    add_column :users, :token, :string
    User.find_each { |user| user.save! }
    # change_column_null :users, :token, false, 1
  end

  def down
    remove_column :users, :token, :string
  end
end

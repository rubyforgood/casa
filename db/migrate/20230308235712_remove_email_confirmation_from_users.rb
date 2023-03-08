class RemoveEmailConfirmationFromUsers < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :users, :email_confirmation, :string }
  end
end
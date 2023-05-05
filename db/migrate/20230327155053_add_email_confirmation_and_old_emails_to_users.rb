class AddEmailConfirmationAndOldEmailsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :old_emails, :string, array: true, default: []
    add_column :users, :email_confirmation, :string
  end
end

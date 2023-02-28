class AddPreviousEmailsToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :old_emails, :string, array: true, default: []
  end
end

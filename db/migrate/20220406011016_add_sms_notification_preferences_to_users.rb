class AddSmsNotificationPreferencesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :receive_sms_notifications, :boolean, null: false, default: false
  end
end

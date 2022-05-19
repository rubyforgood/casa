class CreateUserSmsNotificationEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :user_sms_notification_events do |t|
      t.references :user, null: false, foreign_key: true
      t.references :sms_notification_event, null: false, foreign_key: true

      t.timestamps
    end
  end
end

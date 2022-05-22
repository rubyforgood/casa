class CreateSmsNotificationEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :sms_notification_events do |t|
      t.string :name
      t.string :user_type

      t.timestamps
    end
  end
end

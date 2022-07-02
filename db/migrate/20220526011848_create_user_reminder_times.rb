class CreateUserReminderTimes < ActiveRecord::Migration[7.0]
  def change
    create_table :user_reminder_times do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.datetime :case_contact_types
      t.datetime :no_contact_made

      t.timestamps
    end
  end
end

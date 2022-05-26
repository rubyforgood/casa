class CreateUserCaseContactTypesReminders < ActiveRecord::Migration[7.0]
  def change
    create_table :user_case_contact_types_reminders do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.datetime :reminder_sent

      t.timestamps
    end
  end
end

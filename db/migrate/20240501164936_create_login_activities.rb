class CreateLoginActivities < ActiveRecord::Migration[7.1]
  def change
    create_table :login_activities do |t|
      t.references :user, null: false, foreign_key: true
      t.string :email
      t.datetime :current_sign_in_at
      t.string :current_sign_in_ip
      t.string :user_type

      t.timestamps
    end
  end
end

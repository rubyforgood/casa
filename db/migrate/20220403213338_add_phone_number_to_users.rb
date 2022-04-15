class AddPhoneNumberToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :phone_number, :string, default: ""
  end
end

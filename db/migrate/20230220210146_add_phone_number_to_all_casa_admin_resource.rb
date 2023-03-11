class AddPhoneNumberToAllCasaAdminResource < ActiveRecord::Migration[7.0]
  def change
    add_column :all_casa_admins, :phone_number, :string, default: ""
  end
end

class RemovePhoneNumberFromAllCasaAdminResource < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :all_casa_admins, :phone_number }
  end
end

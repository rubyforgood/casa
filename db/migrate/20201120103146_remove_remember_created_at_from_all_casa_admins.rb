class RemoveRememberCreatedAtFromAllCasaAdmins < ActiveRecord::Migration[6.0]
  def change
    remove_column :all_casa_admins, :remember_created_at, :datetime
  end
end

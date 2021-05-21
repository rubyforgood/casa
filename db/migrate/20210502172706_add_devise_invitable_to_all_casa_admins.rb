class AddDeviseInvitableToAllCasaAdmins < ActiveRecord::Migration[6.1]
  def change
    add_column :all_casa_admins, :invitation_token, :string
    add_column :all_casa_admins, :invitation_created_at, :datetime
    add_column :all_casa_admins, :invitation_sent_at, :datetime
    add_column :all_casa_admins, :invitation_accepted_at, :datetime
    add_column :all_casa_admins, :invitation_limit, :integer
    add_column :all_casa_admins, :invited_by_id, :integer
    add_column :all_casa_admins, :invited_by_type, :string
    add_index :all_casa_admins, :invitation_token, unique: true
  end
end

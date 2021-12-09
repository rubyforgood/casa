class AddShowDrivingReimbursementToCasaOrgs < ActiveRecord::Migration[6.1]
  def change
    add_column :casa_orgs, :show_driving_reimbursement, :boolean, default: true
  end
end

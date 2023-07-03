class AddReceiveReimbursementEmailToUsers < ActiveRecord::Migration[7.0]
  def change
    return if column_exists?(:users, :receive_reimbursement_email)
    add_column :users, :receive_reimbursement_email, :boolean, default: false
  end
end

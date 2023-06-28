class AddReceiveReimbursementEmailToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :receive_reimbursement_email, :boolean, default: false
  end
end

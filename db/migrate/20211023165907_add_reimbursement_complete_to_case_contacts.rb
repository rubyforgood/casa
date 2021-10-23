class AddReimbursementCompleteToCaseContacts < ActiveRecord::Migration[6.1]
  def change
    add_column :case_contacts, :reimbursement_complete, :boolean, default: false
  end
end

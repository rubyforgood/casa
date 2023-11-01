class AddAllowReimbursementToCaseAssignments < ActiveRecord::Migration[7.0]
  def change
    add_column :case_assignments, :allow_reimbursement, :boolean, default: true
  end
end

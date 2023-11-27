class StatusForCaseContacts < ActiveRecord::Migration[7.0]
  def change
    add_column :case_contacts, :status, :integer, default: 0
    add_column :case_contacts, :draft_case_ids, :integer, array: true, default: []
    add_column :case_contacts, :volunteer_address, :string

    # We need these columns to be nil if the case_contact is in_progress (ie. DRAFT mode)
    change_column_null :case_contacts, :casa_case_id, true
    change_column_null :case_contacts, :duration_minutes, true
    change_column_null :case_contacts, :occurred_at, true
  end
end

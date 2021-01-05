class AddFollowupCreatedAtToCaseContacts < ActiveRecord::Migration[6.1]
  def change
    add_column :case_contacts, :followup_created_at, :datetime
  end
end

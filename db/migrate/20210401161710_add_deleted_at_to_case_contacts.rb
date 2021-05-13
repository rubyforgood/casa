class AddDeletedAtToCaseContacts < ActiveRecord::Migration[6.1]
  def change
    add_column :case_contacts, :deleted_at, :datetime
    add_index :case_contacts, :deleted_at
  end
end

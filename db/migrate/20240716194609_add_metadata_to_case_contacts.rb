class AddMetadataToCaseContacts < ActiveRecord::Migration[7.1]
  def change
    add_column :case_contacts, :metadata, :jsonb, default: {}
  end
end

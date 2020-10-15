class RemoveContactTypesFromCaseContacts < ActiveRecord::Migration[6.0]
  def change
    # case_contacts.contact_types has been deprecated in favor of case_contact.case_contact_contact_type
    remove_column :case_contacts, :contact_types, :string, array: true, default: []
  end
end

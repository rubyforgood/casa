class AddMediumTypeAndContactMadeToCaseContacts < ActiveRecord::Migration[6.0]
  def change
    add_column :case_contacts, :contact_made, :boolean, default: false
    add_column :case_contacts, :medium_type, :string
  end
end

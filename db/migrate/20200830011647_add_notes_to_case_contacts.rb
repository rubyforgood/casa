class AddNotesToCaseContacts < ActiveRecord::Migration[6.0]
  def change
    add_column :case_contacts, :notes, :string
  end
end

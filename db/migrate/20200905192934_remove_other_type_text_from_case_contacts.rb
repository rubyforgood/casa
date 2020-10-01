class RemoveOtherTypeTextFromCaseContacts < ActiveRecord::Migration[6.0]
  def change
    remove_column :case_contacts, :other_type_text, :string
  end
end

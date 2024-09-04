class ChangeCaseContactsContactMadeDefaultValue < ActiveRecord::Migration[7.1]
  def change
    change_column_default :case_contacts, :contact_made, true
  end
end

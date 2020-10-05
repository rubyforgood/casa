class LinkCaseContactsToContactTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :case_contact_contact_types do |t|
      t.references :case_contact, null: false
      t.references :contact_type, null: false

      t.timestamps
    end
  end
end

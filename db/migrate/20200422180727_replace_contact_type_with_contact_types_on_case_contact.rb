class ReplaceContactTypeWithContactTypesOnCaseContact < ActiveRecord::Migration[6.0]
  def change

    # NOTE: This is a destructive migration that we would normally avoid
    #       if we were working on production data, but because there is
    #       no production data we are comfortable being destructive and
    #       losting whatever data is in the `contact_type` column.
    remove_column :case_contacts, :contact_type
    add_column :case_contacts, :contact_types, :string, array: true
    add_index :case_contacts, :contact_types, using: :gin
  end
end

class AddEnumStatusToCaseContact < ActiveRecord::Migration[7.0]
  def up
    add_column :case_contacts, :status, :integer, default: 0, null: false
  end

  def down
    remove_column :case_contacts, :status
  end
end

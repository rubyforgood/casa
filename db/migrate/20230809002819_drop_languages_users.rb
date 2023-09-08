class DropLanguagesUsers < ActiveRecord::Migration[7.0]
  def up
    drop_table :languages_users
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end

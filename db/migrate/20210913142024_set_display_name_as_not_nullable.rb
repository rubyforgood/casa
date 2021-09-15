class SetDisplayNameAsNotNullable < ActiveRecord::Migration[6.1]
  def up
    change_column :users, :display_name, :string, null: false
  end

  def down
    change_column :users, :display_name, :string, null: true
  end
end

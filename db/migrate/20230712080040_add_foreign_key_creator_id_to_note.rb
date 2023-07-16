class AddForeignKeyCreatorIdToNote < ActiveRecord::Migration[7.0]
  def up
    add_foreign_key :notes, :users, column: :creator_id, validate: false
  end

  def down
    remove_foreign_key :notes, :creator_id
  end
end

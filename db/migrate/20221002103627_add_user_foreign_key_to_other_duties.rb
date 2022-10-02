class AddUserForeignKeyToOtherDuties < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :other_duties, :users, column: :creator_id, validate: false
  end
end

class ValidateAddUserForeignKeyToOtherDuties < ActiveRecord::Migration[7.0]
  def change
    validate_foreign_key :other_duties, :users
  end
end

class ChangeCaseUpdateUserToCreator < ActiveRecord::Migration[6.0]
  def change
    add_reference :case_updates, :creator, foreign_key: { to_table: :users }, null: false
    # if there were data in prod, you would have to copy the data over from the old to the new column
    remove_reference :case_updates, :user
  end
end

class CreateLanguagesUsersJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :languages, :users do |t|
      t.index :language_id
      t.index :user_id
    end
  end
end

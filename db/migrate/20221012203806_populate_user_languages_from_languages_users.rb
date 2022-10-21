class PopulateUserLanguagesFromLanguagesUsers < ActiveRecord::Migration[7.0]
  def change
    query = Arel.sql("select language_id, user_id from languages_users")
    old_join_table_entries = ActiveRecord::Base.connection.execute(query).to_a

    old_join_table_entries.each do |entry|
      UserLanguage.create(user_id: entry["user_id"], language_id: entry["language_id"])
    end
  end
end

class RemoveDuplicateIndexindexUserLanguagesOnLanguageId < ActiveRecord::Migration[7.2]
  def change
    remove_index :user_languages, :language_id
  end
end

class AddNoteToFollowups < ActiveRecord::Migration[6.1]
  def change
    add_column :followups, :note, :text
  end
end

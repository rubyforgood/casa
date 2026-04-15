class AddDeletedAtToContactTopicAnswers < ActiveRecord::Migration[7.2]
  def change
    add_column :contact_topic_answers, :deleted_at, :datetime
  end
end

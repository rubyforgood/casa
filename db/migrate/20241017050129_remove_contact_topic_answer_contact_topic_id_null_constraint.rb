class RemoveContactTopicAnswerContactTopicIdNullConstraint < ActiveRecord::Migration[7.2]
  def change
    change_column_null(:contact_topic_answers, :contact_topic_id, true)
  end
end

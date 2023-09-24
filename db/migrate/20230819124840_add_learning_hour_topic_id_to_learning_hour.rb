class AddLearningHourTopicIdToLearningHour < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :learning_hours, :learning_hour_topic, index: {algorithm: :concurrently}
  end
end

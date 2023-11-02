class AddLearningTopicActiveToCasaOrg < ActiveRecord::Migration[7.0]
  def change
    add_column :casa_orgs, :learning_topic_active, :boolean, default: false
  end
end

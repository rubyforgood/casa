class AddContactTopics < ActiveRecord::Migration[7.1]
  def change
    create_table :contact_topics do |t|
      t.references :casa_org, null: false, foreign_key: true
      t.boolean :active, null: false, default: true
      t.boolean :soft_delete, null: false, default: false
      t.text :details
      t.string :question

      t.timestamps
    end

    create_table :contact_topic_answers do |t|
      t.text :value
      t.references :case_contact, null: false, foreign_key: true
      t.references :contact_topic, null: false, foreign_key: true
      t.boolean :selected, null: false, default: false

      t.timestamps
    end
  end
end

class AddIndexesRfg2025 < ActiveRecord::Migration[7.2]
  def change
    add_index :action_text_rich_texts, [:record_type, :record_id], algorithm: :concurrently
    add_index :all_casa_admins, [:invited_by_id, :invited_by_type], algorithm: :concurrently
    add_index :api_credentials, :user_id, algorithm: :concurrently
    add_index :banners, :casa_org_id, algorithm: :concurrently
    add_index :banners, :user_id, algorithm: :concurrently
    add_index :banners, [:user_id, :casa_org_id], algorithm: :concurrently
    add_index :casa_cases_emancipation_options, :casa_case_id, algorithm: :concurrently
    add_index :case_group_memberships, :case_group_id, algorithm: :concurrently
    add_index :case_group_memberships, :casa_case_id, algorithm: :concurrently
    add_index :case_groups, :casa_org_id, algorithm: :concurrently
    add_index :checklist_items, :hearing_type_id, algorithm: :concurrently
    add_index :contact_topic_answers, :contact_topic_id, algorithm: :concurrently
    add_index :contact_topics, :casa_org_id, algorithm: :concurrently
    add_index :contact_type_groups, :casa_org_id, algorithm: :concurrently
    add_index :emancipation_options, :emancipation_category_id, algorithm: :concurrently

  end
end

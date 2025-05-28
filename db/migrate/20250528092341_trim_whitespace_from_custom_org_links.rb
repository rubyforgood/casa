class TrimWhitespaceFromCustomOrgLinks < ActiveRecord::Migration[7.2]
  def up
    CustomOrgLink.find_each do |link|
      trimmed_text = link.text.strip
      link.update_columns(text: trimmed_text) if trimmed_text.present?
    rescue => e
      Rails.logger.error("Failed to update CustomOrgLink ##{link.id}: #{e.message}")
    end
  end

  def down
    Rails.logger.info("Rollback not implemented for TrimWhitespaceFromCustomOrgLinks as it is a data migration")
  end
end

class AddExcludeFromCourtReportToContactTopics < ActiveRecord::Migration[7.2]
  def change
    add_column :contact_topics, :exclude_from_court_report, :boolean, default: false, null: false
  end
end

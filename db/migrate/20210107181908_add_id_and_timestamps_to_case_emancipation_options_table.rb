class AddIdAndTimestampsToCaseEmancipationOptionsTable < ActiveRecord::Migration[6.1]
  def change
    add_column :casa_cases_emancipation_options, :id, :primary_key
    add_timestamps :casa_cases_emancipation_options, default: Time.zone.now
    change_column_default :casa_cases_emancipation_options, :created_at, nil
    change_column_default :casa_cases_emancipation_options, :updated_at, nil
  end
end

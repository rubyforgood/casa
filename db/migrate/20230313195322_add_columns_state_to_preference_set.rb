class AddColumnsStateToPreferenceSet < ActiveRecord::Migration[7.0]
  def change
    add_column :preference_sets, :table_state, :jsonb, default: {}
  end
end

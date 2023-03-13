class AddColumnsStateToPreferenceSet < ActiveRecord::Migration[7.0]
  def change
    add_column :preference_sets, :columns_state, :text
  end
end

class RemoveNullCheckDeprecatedField < ActiveRecord::Migration[6.1]
  def change
    change_column_null :casa_cases, :transition_aged_youth, true
  end
end

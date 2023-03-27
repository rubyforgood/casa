class PreferenceSetTableStateService
  attr_reader :current_user
  
  def initialize( current_user:)
    @current_user = current_user
  end

  def fetch_table_state( table_name:)
    preference_set = PreferenceSet.find_or_create_by(user: @current_user)
    preference_set.table_state[table_name]
  end

  def save_table_state(table_state:, table_name:)
    preference_set = PreferenceSet.find_or_create_by(user: @current_user)
    preference_set.table_state[table_name] = table_state
    preference_set.save
  end
end
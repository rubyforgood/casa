class PreferenceSetTableStateService
  attr_reader :table_name, :table_state, :current_user, :params
  
  def initialize(table_name:, table_state:, current_user:, params:)
    @table_state = table_state
    @table_name = table_name
    @current_user = current_user
    @params = params
  end

  def call
    if  @params["action"] == "save_table_state"
      save_table_state
    elsif @params["action"] == "table_state"
      fetch_table_state
    end
  end

  private 
  def fetch_table_state
    preference_set = PreferenceSet.find_or_create_by(user: @current_user)
    preference_set.table_state[@table_name]
  end

  def save_table_state
    preference_set = PreferenceSet.find_or_create_by(user: @current_user)
    preference_set.table_state[@table_name] = table_state
    preference_set.save
  end
end
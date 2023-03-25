class SaveTableStateService
  attr_reader :table_name, :table_state
  
  def initialize(table_name:, table_state:, current_user:)
    @table_state = table_state
    @table_name = table_name
    @current_user = current_user
  end
  
  def call
    preference_set = PreferenceSet.find_or_create_by(user: @current_user)
    preference_set.table_state[@table_name] = table_state
    preference_set.save
  end
end

class PreferenceSetTableStateService
  def initialize(user_id:)
    @user_id = user_id
  end

  def table_state(table_name:)
    # table_state = JSON.parse(preference_set.table_state)
    # if table_state[table_name].nil?
      # table_state[table_name] = {}
    # else
      #  preference_set.table_state[table_name]
    # end

    preference_set.table_state[table_name]
  end

  def update!(table_name:, table_state:)
    preference_set.table_state[table_name] = table_state
    preference_set.save!
  end

  private
  attr_reader :user_id

  def preference_set
    @preference_set ||= PreferenceSet.find_by!(user_id: @user_id)
  end
end
class PreferenceSetTableStateService
  def initialize(user_id:)
    @user_id = user_id
  end

  def table_state(table_name:)
    preference_set.table_state[table_name]
  end

  def update!(table_name:, table_state:)
    preference_set.table_state[table_name] = table_state
    preference_set.save!

    unless preference_set.save
      raise UpdateFailedError, "Failed to update table state for table_name: '#{table_name}'"
    end
  end

private
  attr_reader :user_id
  def preference_set
    @preference_set ||= PreferenceSet.find_by!(user_id: user_id)
  end


 class UpdateFailedError < StandardError; end
end
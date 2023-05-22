class PreferenceSetTableStateService
   class TableStateUpdateFailed < StandardError; end
   def initialize(user_id:)
     @user_id = user_id
   end

   def table_state(table_name:)
     preference_set.table_state[table_name]
   end

   def update!(table_name:, table_state:)
     preference_set.table_state[table_name] = table_state
     preference_set.save!

       rescue StandardError
         raise TableStateUpdateFailed, "Failed to update table state for '#{table_name}'"
   end

 private
   attr_reader :user_id
   def preference_set
     @preference_set ||= PreferenceSet.find_by!(user_id: user_id)
   end

 end
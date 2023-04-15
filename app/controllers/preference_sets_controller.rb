class PreferenceSetsController < ApplicationController
  def table_state
    skip_authorization
    render json: PreferenceSetTableStateService.new(user_id: current_user.id).table_state(
      table_name: "volunteers_table"
    )
  end

  def table_state_update
    skip_authorization
    render json: PreferenceSetTableStateService.new(user_id: current_user.id).update!(
      table_state: params["table_state"],
      table_name: "volunteers_table"
    )
  end
end
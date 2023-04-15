class PreferenceSetsController < ApplicationController
  before_action :skip_authorization
  def table_state
    render json: PreferenceSetTableStateService.new(user_id: current_user.id).table_state(
      table_name: "volunteers_table"
    )
  end

  def table_state_update
    render json: PreferenceSetTableStateService.new(user_id: current_user.id).update!(
      table_state: params["table_state"],
      table_name: "volunteers_table"
    )
  end
end
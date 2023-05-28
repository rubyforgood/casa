class PreferenceSetsController < ApplicationController
  before_action :skip_authorization, :set_table_name
  def table_state
    render json: PreferenceSetTableStateService.new(user_id: current_user.id).table_state(
      table_name: @table_name
    )
  end

  def table_state_update
    render json: PreferenceSetTableStateService.new(user_id: current_user.id).update!(
      table_state: params["table_state"],
      table_name: @table_name
    )
  rescue PreferenceSetTableStateService::TableStateUpdateFailed
    render json: {error: "Failed to update table state for '#{@table_name}'"}
  end

  private

  def set_table_name
    @table_name = params[:table_name]
  end
end

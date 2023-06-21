class SystemSettingsController < ApplicationController
  after_action :verify_authorized

  def index
    authorize :application, :edit_system_settings?

    @show_additional_expenses = FeatureFlagService.is_enabled?(FeatureFlagService::SHOW_ADDITIONAL_EXPENSES_FLAG)
  end

  def create
    authorize :application, :edit_system_settings?

    if params[:show_additional_expenses]
      FeatureFlagService.enable!(FeatureFlagService::SHOW_ADDITIONAL_EXPENSES_FLAG)
    else
      FeatureFlagService.disable!(FeatureFlagService::SHOW_ADDITIONAL_EXPENSES_FLAG)
    end
  end
end

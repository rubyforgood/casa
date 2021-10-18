class HealthController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    render json: {last_deploy_timestamp: Rails.application.config.latest_deploy_time}
  end
end

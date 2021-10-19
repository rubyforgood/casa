class HealthController < ApplicationController
  def index
    render json: {last_deploy_timestamp: Rails.application.config.latest_deploy_time}
  end
end

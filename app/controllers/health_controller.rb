class HealthController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    render json: {latest_deploy_time: Rails.application.config.latest_deploy_time}
  end
end

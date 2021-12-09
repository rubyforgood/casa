class HealthController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    render json: {latest_deploy_time: Health.instance.latest_deploy_time}
  end
end

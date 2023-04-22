class HealthController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    respond_to do |format|
      format.html do
        render :index
      end

      format.json { render json: {latest_deploy_time: Health.instance.latest_deploy_time} }
    end
  end
end

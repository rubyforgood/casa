class HealthController < ApplicationController
  def index
    render json: {last_deploy_timestamp: File.mtime("app")}
  end
end

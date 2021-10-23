class HealthController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    unless Rails.application.config.respond_to?(:latest_deploy_time)

      Rails.application.config.latest_deploy_time = JSON.parse(File.read(Rails.root.join("tmp", "deploy_time.json").to_s))['latest_deploy_time']
    end

    render json: {latest_deploy_time: Rails.application.config.latest_deploy_time}
  end
end

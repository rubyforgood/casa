# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  include Accessible
  skip_before_action :check_user, only: :destroy
  def create
    respond_to do |format|
      format.html { super }
      format.json {
        warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#faliure")
        render json: "Successfully authenticated", status: 200
      }
    end
  end

  # API authentication error
  def faliure
    render json: "Something went wrong with API sign in :(", status: 401
  end
end

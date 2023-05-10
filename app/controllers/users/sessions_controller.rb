# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  #respond_to :json
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

  private

  def respond_to_on_destroy
    # We actually need to hardcode this as Rails default responder doesn't
    # support returning empty response on GET request
    respond_to do |format|
      format.json {
        render json: "Successfully Signed Out", status: 200
      }
      format.all { head :no_content }
      format.any(*navigational_formats) { redirect_to after_sign_out_path_for(resource_name), status: Devise.responder.redirect_status }
    end
  end
end

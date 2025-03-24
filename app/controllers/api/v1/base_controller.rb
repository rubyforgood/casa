class Api::V1::BaseController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  before_action :authenticate_user!, except: [:create, :destroy]

  def authenticate_user!
    api_token, options = ActionController::HttpAuthentication::Token.token_and_options(request)
    user = User.find_by(email: options[:email])
    if user && api_token && ActiveSupport::SecurityUtils.secure_compare(user.api_credential.api_token_digest, Digest::SHA256.hexdigest(api_token))
      @current_user = user
    else
      render json: {message: "Incorrect email or password."}, status: 401
    end
  end

  def not_found
    api_error(status: 404, errors: "Not found")
  end
end

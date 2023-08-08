class Api::V1::BaseController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  before_action :authenticate_user!, except: [:create]

  def authenticate_user!
    token, options = ActionController::HttpAuthentication::Token.token_and_options(request)
    # return nil unless token && options.is_a?(Hash)
    print options
    user = User.find_by(email: options[:email])
    p "#######"
    print token
    p "#######"
    if user && token && ActiveSupport::SecurityUtils.secure_compare(user.token, token)
      @current_user = user
    else
      render json: {message: "Wrong password or email"}, status: 401
    end
  end

  def not_found
    api_error(status: 404, errors: "Not found")
  end
end

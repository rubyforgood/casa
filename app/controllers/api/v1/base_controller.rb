class Api::V1::BaseController < ActionController::API
rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def authenticate_user!
    token, options = ActionController::HttpAuthentication::Token.token_and_options(request)
    return nil unless token && options.is_a?(hash)
    user = User.find_by(email: options[:email])
    if user && ActiveSupport::SecurityUtils.secure_compare(user.token, token)
      @current_user = user
    else
      return UnauthenticatedError
    end
  end

  def not_found
    return api_error(status: 404, errors: 'Not found')
  end
end

class Api::V1::Users::SessionsController < Api::V1::BaseController
  def create
    load_resource
    if @user
      render json: Api::V1::SessionBlueprint.render(@user, remember_me: user_params[:remember_me]), status: 201
    else
      render json: {message: "Incorrect email or password."}, status: 401
    end
  end

  def destroy
    # fetch access token from request header
    api_token = request.headers["Authorization"]&.split(" ")&.last
    # find user's api credentials by access token
    api_credential = ApiCredential.find_by(api_token_digest: Digest::SHA256.hexdigest(api_token))
    # set api and refresh tokens to nil; otherwise render 401
    if api_credential
      api_credential.revoke_api_token
      api_credential.revoke_refresh_token
      render json: {message: "Signed out successfully."}, status: 200
    else
      render json: {message: "An error occured when signing out."}, status: 401
      nil
    end
  end

  private

  def user_params
    params.permit(:email, :password, :remember_me)
  end

  def load_resource
    @user = User.find_by(email: user_params[:email])
    unless @user&.valid_password?(user_params[:password])
      @user = nil
    end
  end
end

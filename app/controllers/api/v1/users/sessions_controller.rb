class Api::V1::Users::SessionsController < Api::V1::BaseController
  def create
    load_resource
    if @user
      render json: Api::V1::SessionBlueprint.render(@user), status: 201
    else
      render json: {message: "Incorrect email or password."}, status: 401
    end
  end

  def destroy
    # fetch refresh token from request header
    refresh_token = request.headers["Authorization"]&.split(" ")&.last
    # find user's api credentials by refresh token
    api_credential = ApiCredential.find_by(refresh_token_digest: Digest::SHA256.hexdigest(refresh_token))
    # set api and refresh tokens to nil; otherwise render 401
    if api_credential
      api_credential.revoke_token("api_token")
      api_credential.revoke_token("refresh_token")
      render json: {message: "Signed out successfully."}, status: 200
    else
      render json: {message: "An error occured when signing out."}, status: 401
      return
    end
  end

  private

  def user_params
    params.permit(:email, :password)
  end

  def load_resource
    @user = User.find_by(email: user_params[:email])
    unless @user&.valid_password?(user_params[:password])
      @user = nil
    end
  end
end

class Api::V1::Users::SessionsController < Api::V1::BaseController
  def create
    load_resource
    if @user
      render json: Api::V1::SessionBlueprint.render(@user), status: 201
    else
      render json: {message: "Wrong password or email"}, status: 401
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

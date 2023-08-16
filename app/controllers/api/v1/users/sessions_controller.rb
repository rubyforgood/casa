class Api::V1::Users::SessionsController < Api::V1::BaseController
  # POST /api/v1/users/sign_in
  def create
    load_resource
    # p @user
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
    # print user_params
    # print user_params
    @user = User.find_by(email: user_params[:email])
    if !@user&.valid_password?(user_params[:password])
      @user = nil
    end
    # @user = User.find_by(email: user_params[:email])&.valid_password?(user_params[:password])
  end
end

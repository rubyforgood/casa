class UsersController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(user_params)
      flash[:success] = "Profile was successfully updated."
      redirect_to edit_users_path
    else
      render :edit
    end
  end

  def update_password
    @user = current_user
    if @user.update(password_params)
      bypass_sign_in(@user)
      flash[:success] = "Password was successfully updated."
      redirect_to edit_users_path
    else
      render "edit"
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def user_params
    if current_user.casa_admin?
      params.require(:user).permit(:email, :display_name)
    else
      params.require(:user).permit(:display_name)
    end
  end
end

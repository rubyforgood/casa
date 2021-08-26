class UsersController < ApplicationController
  after_action :verify_authorized

  def edit
    @user = current_user
    authorize @user, policy_class: UserPolicy
    @active_casa_admins = CasaAdmin.in_organization(current_organization).active
  end

  def update
    @user = current_user
    authorize @user, policy_class: UserPolicy

    if @user.update(user_params)
      flash[:success] = "Profile was successfully updated."
      redirect_to edit_users_path
    else
      @active_casa_admins = CasaAdmin.in_organization(current_organization).active
      render :edit
    end
  end

  def update_password
    @user = current_user
    authorize @user, policy_class: UserPolicy

    if @user.valid_password?(password_params[:current_password])
      password_thing = {password: password_params[:password], password_confirmation: password_params[:password_confirmation]}

      if @user.update(password_thing)
        bypass_sign_in(@user)
        flash[:success] = "Password was successfully updated."
        redirect_to edit_users_path
      else
        render "edit"
      end
    else
      flash[:error] = "Current password is incorrect"
      render "edit"
    end
  end

  private

  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

  def user_params
    if current_user.casa_admin?
      params.require(:user).permit(:email, :display_name)
    else
      params.require(:user).permit(:display_name)
    end
  end
end

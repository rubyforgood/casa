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

    if @user.update(password_params)
      bypass_sign_in(@user)

      UserMailer.password_changed_reminder(@user).deliver
      flash[:success] = "Password was successfully updated."

      redirect_to edit_users_path
    else
      @active_casa_admins = CasaAdmin.in_organization(current_organization).active
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

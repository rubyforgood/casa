class UsersController < ApplicationController
  before_action :get_user
  before_action :authorize_user_with_policy
  before_action :set_active_casa_admins
  after_action :verify_authorized
  before_action :set_custom_error_heading, only: [:update_password]
  after_action :reset_custom_error_heading, only: [:update_password]

  def edit
  end

  def update
    if @user.update(user_params)
      flash[:success] = "Profile was successfully updated."
      redirect_to edit_users_path
    else
      render :edit
    end
  end

  def update_password
    unless valid_user_password
      @user.errors.add(:base, "Current password is incorrect")
      return render "edit"
    end

    unless update_user_password
      return render "edit"
    end

    bypass_sign_in(@user) if @user == true_user

    UserMailer.password_changed_reminder(@user).deliver
    flash[:success] = "Password was successfully updated."

    redirect_to edit_users_path
  end

  private

  def set_active_casa_admins
    @active_casa_admins = CasaAdmin.in_organization(current_organization).active
  end

  def authorize_user_with_policy
    authorize @user, policy_class: UserPolicy
  end

  def get_user
    @user = current_user
  end

  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

  def update_user_password
    @user.update({password: password_params[:password], password_confirmation: password_params[:password_confirmation]})
  end

  def user_params
    if current_user.casa_admin?
      params.require(:user).permit(:email, :display_name, :phone_number, :receive_sms_notifications, :receive_email_notifications)
    else
      params.require(:user).permit(:display_name, :phone_number, :receive_sms_notifications, :receive_email_notifications)
    end
  end

  def valid_user_password
    @user.valid_password?(password_params[:current_password])
  end

  def set_custom_error_heading
    @custom_error_header = "password change"
  end

  def reset_custom_error_heading
    @custom_error_header = nil
  end
end

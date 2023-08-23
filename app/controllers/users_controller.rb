class UsersController < ApplicationController
  before_action :get_user
  before_action :authorize_user_with_policy
  before_action :set_active_casa_admins
  before_action :set_language, only: %i[add_language remove_language]
  after_action :verify_authorized
  before_action :set_custom_error_heading, only: [:update_password]
  after_action :reset_custom_error_heading, only: [:update_password]

  def edit
    set_initial_address
  end

  def update
    if @user.update(user_params)
      flash[:success] = "Profile was successfully updated."
      redirect_to edit_users_path
    else
      render :edit
    end
  end

  def add_language
    if @language.nil?
      @user.errors.add(:language_id, "can not be blank. Please select a language before adding.")
      render :edit
    else
      if current_user.languages.include?(@language)
        flash[:alert] = "#{@language.name} is already in your languages list."
      elsif current_user.languages << @language && current_user.save
        flash[:notice] = "#{@language.name} was added to your languages list."
      else
        flash[:alert] = "Error unable to add #{@language.name} to your languages list!"
      end
      redirect_to edit_users_path
    end
  end

  def remove_language
    set_language
    raise ActiveRecord::RecordNotFound unless @language

    current_user.languages.delete @language
    if current_user.save
      redirect_to edit_users_path, notice: "#{@language.name} was removed from your languages list."
    else
      redirect_to edit_users_path, alert: "Unable to remove language."
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

  def update_email
    unless valid_user_password
      @user.errors.add(:base, "Current password is incorrect")
      return render "edit"
    end

    unless update_user_email
      return render "edit"
    end

    bypass_sign_in(@user) if @user == true_user

    redirect_to edit_users_path
  end

  private

  def set_language
    @language = Language.find_by(id: params[:id] || params[:language_id])
  end

  def set_initial_address
    Address.create(user_id: current_user.id, content: "") if !current_user.address
  end

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

  def email_params
    params.require(:user).permit(:current_password, :email, :unconfirmed_email)
  end

  def update_user_email
    @user.update({email: email_params[:email]})
    @user.filter_old_emails!(@user.email)
  end

  def user_params
    if !current_user.casa_admin?
      params.require(:user).permit(:display_name, :phone_number, :receive_sms_notifications, :receive_email_notifications, sms_notification_event_ids: [], address_attributes: [:id, :content])
    else
      params.require(:user).permit(:email, :display_name, :phone_number, :receive_sms_notifications, :receive_email_notifications, sms_notification_event_ids: [], address_attributes: [:id, :content])
    end
  end

  def valid_user_password
    if password_params
      @user.valid_password?(password_params[:current_password])
    elsif email_params
      @user.valid_password?(email_params[:current_password])
    end
  end

  def set_custom_error_heading
    @custom_error_header = "password change"
  end

  def reset_custom_error_heading
    @custom_error_header = nil
  end
end

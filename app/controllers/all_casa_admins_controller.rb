class AllCasaAdminsController < ApplicationController
  before_action :authenticate_all_casa_admin!

  def edit
    @user = current_all_casa_admin
  end

  def update
    @user = current_all_casa_admin

    if @user.update(all_casa_admin_params)
      flash[:success] = "Profile was successfully updated."
      redirect_to edit_all_casa_admins_path
    else
      render :edit
    end
  end

  def update_password
    @user = current_all_casa_admin
    if @user.update(password_params)
      bypass_sign_in(@user)
      flash[:success] = "Password was successfully updated."
      redirect_to edit_all_casa_admins_path
    else
      render "edit"
    end
  end

  private

  def all_casa_admin_params
    params.require(:all_casa_admin).permit(:email)
  end

  def password_params
    params.require(:all_casa_admin).permit(:password, :password_confirmation)
  end
end

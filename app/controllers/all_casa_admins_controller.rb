class AllCasaAdminsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :authenticate_all_casa_admin!
  before_action :set_custom_error_heading, only: [:update_password]
  after_action :reset_custom_error_heading, only: [:update_password]
  skip_after_action :verify_authorized

  def new
    @all_casa_admin = AllCasaAdmin.new
  end

  def edit
    @user = current_all_casa_admin
  end

  def create
    service = ::CreateAllCasaAdminService.new(params, current_user)
    @all_casa_admin = service.build

    begin
      service.create!

      respond_to do |format|
        format.html do
          redirect_to authenticated_all_casa_admin_root_path,
            notice: "New All CASA admin created successfully"
        end

        format.json { render json: @all_casa_admin, status: :created }
      end
    rescue ActiveRecord::RecordInvalid
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }

        format.json do
          render json: @all_casa_admin.errors.full_messages, status: :unprocessable_entity
        end
      end
    end
  end

  def update
    @user = current_all_casa_admin

    if @user.update(all_casa_admin_params)
      respond_to do |format|
        format.html do
          flash[:success] = "Profile was successfully updated."
          redirect_to edit_all_casa_admins_path
        end

        format.json { render json: @user, status: :ok }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  def update_password
    @user = current_all_casa_admin

    if @user.update(password_params)
      bypass_sign_in(@user)

      UserMailer.password_changed_reminder(@user).deliver

      respond_to do |format|
        format.html do
          flash[:success] = "Password was successfully updated."

          redirect_to edit_all_casa_admins_path
        end

        format.json { render json: "Password was successfully updated.", status: :ok }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  private

  def all_casa_admin_params
    params.require(:all_casa_admin).permit(:email)
  end

  def password_params
    params.require(:all_casa_admin).permit(:password, :password_confirmation)
  end

  def set_custom_error_heading
    @custom_error_header = "password change"
  end

  def reset_custom_error_heading
    @custom_error_header = nil
  end
end

class CasaAdminsController < ApplicationController
  before_action :authenticate_user!, :must_be_admin
  before_action :set_admin, except: [:index, :new, :create]
  before_action :require_organization!

  def index
    @admins = policy_scope(current_organization.casa_admins)
  end

  def edit
  end

  def update
    if @casa_admin.update(update_casa_admin_params)
      redirect_to root_path, notice: "Admin was successfully updated."
    else
      render :edit
    end
  end

  def new
    @casa_admin = CasaAdmin.new
  end

  def create
    @casa_admin = CasaAdmin.new(create_casa_admin_params)

    if @casa_admin.save
      @casa_admin.invite!
      redirect_to root_path, notice: "New Admin created."
    else
      render new_casa_admin_path
    end
  end

  def activate
    if @casa_admin.activate
      CasaAdminMailer.account_setup(@casa_admin).deliver

      redirect_to edit_casa_admin_path(@casa_admin), notice: "Admin was activated."
    else
      render :edit
    end
  end

  def deactivate
    if @casa_admin.deactivate
      CasaAdminMailer.deactivation(@casa_admin).deliver

      redirect_to edit_casa_admin_path(@casa_admin), notice: "Admin was deactivated."
    else
      render :edit
    end
  end

  private

  def set_admin
    @casa_admin = CasaAdmin.find(params[:id])
  end

  def update_casa_admin_params
    CasaAdminParameters.new(params).with_only(:email, :display_name)
  end

  def create_casa_admin_params
    CasaAdminParameters.new(params)
      .with_password(SecureRandom.hex(10))
      .with_organization(current_organization)
      .without(:active, :type)
  end
end

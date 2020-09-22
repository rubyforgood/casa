class CasaAdminsController < ApplicationController
  before_action :authenticate_user!, :must_be_admin
  before_action :set_admin, only: [:edit, :update]

  def edit; end

  def update
    if @admin.update(update_casa_admin_params)
      redirect_to root_path, notice: "Admin was successfully updated."
    else
      render :edit
    end
  end

  def new
    @casa_admin = CasaAdmin.new
  end

  def create
    @casa_admin = CasaAdmin.new(casa_admin_params.merge(casa_admin_values) )

    if @casa_admin.save
      @casa_admin.invite!
      flash[:notice] = "New Admin created."
      redirect_to root_path
    else
      render new_casa_admin_path
    end
  end

  private

  def set_admin
    @admin = CasaAdmin.find(params[:id])
  end

  def update_casa_admin_params
    CasaAdminParameters.new(params)
  end

  def casa_admin_values
    { password: SecureRandom.hex(10), casa_org_id: current_user.casa_org_id }
  end

  def casa_admin_params
    params.require(:casa_admin).permit(:display_name, :email, :password, :casa_org_id)
  end
end

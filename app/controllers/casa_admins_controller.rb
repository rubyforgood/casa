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

  private

  def set_admin
    @admin = CasaAdmin.find(params[:id])
  end

  def update_casa_admin_params
    CasaAdminParameters
      .new(params)
      .without_active
  end
end

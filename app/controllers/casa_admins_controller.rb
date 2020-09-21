class CasaAdminsController < ApplicationController
  before_action :authenticate_user!
  before_action :must_be_admin, only: [:new, :create]

  def new
    @casa_admin = CasaAdmin.new
  end

  def create
    @casa_admin = CasaAdmin.new(casa_admin_params.merge(casa_admin_values) )

    if @casa_admin.save
      @casa_admin.invite!
      redirect_to root_path
    else
      render new_casa_admin_path
    end
  end

  private

  def casa_admin_values
    {password: SecureRandom.hex(10), casa_org_id: current_user.casa_org_id}
  end

  def casa_admin_params
    params.require(:casa_admin).permit(:display_name, :email)
  end
end
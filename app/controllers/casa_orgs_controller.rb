class CasaOrgsController < ApplicationController
  before_action :authenticate_user!, :must_be_admin
  before_action :set_casa_org, only: %i[edit update]
  before_action :set_contact_type_data, only: %i[edit update]
  before_action :set_hearing_types, only: %i[edit update]
  before_action :set_judges, only: %i[edit update]
  before_action :must_be_admin
  before_action :require_organization!

  def edit
  end

  def update
    respond_to do |format|
      if @casa_org.update(casa_org_update_params)
        @casa_org.logo.attach(casa_org_update_params[:logo])
        format.html { redirect_to edit_casa_org_path, notice: "CASA organization was successfully updated." }
        format.json { render :show, status: :ok, location: @casa_org }
      else
        format.html { render :edit }
        format.json { render json: @casa_org.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_casa_org
    @casa_org = current_organization
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def casa_org_update_params
    params.require(:casa_org).permit(:name, :display_name, :address, :logo)
  end

  def set_contact_type_data
    @contact_type_groups = @casa_org.contact_type_groups
    @contact_types = ContactType.for_organization(@casa_org)
  end

  def set_hearing_types
    @hearing_types = HearingType.for_organization(@casa_org)
  end

  def set_judges
    @judges = Judge.for_organization(@casa_org)
  end
end

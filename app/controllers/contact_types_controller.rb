class ContactTypesController < ApplicationController
  layout "casa_app"
  before_action -> { @active_nav = "settings" }
  before_action :set_contact_type, except: [:new, :create]
  after_action :verify_authorized

  def new
    authorize ContactType
    @contact_type = ContactType.new
  end

  def create
    authorize ContactType
    @contact_type = ContactType.new(contact_type_params)

    if @contact_type.save
      redirect_to edit_casa_org_path(current_organization), notice: "Contact Type was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @contact_type
  end

  def update
    authorize @contact_type
    if @contact_type.update(contact_type_params)
      redirect_to edit_casa_org_path(current_organization), notice: "Contact Type was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_contact_type
    @contact_type = ContactType.find(params[:id])
  end

  # The group decides which org a contact type belongs to, so it must come from the current org.
  def contact_type_params
    permitted = params.require(:contact_type).permit(:name, :contact_type_group_id, :active)
    if permitted[:contact_type_group_id].present?
      permitted[:contact_type_group_id] = current_organization.contact_type_groups.find(permitted[:contact_type_group_id]).id
    end
    permitted
  end
end

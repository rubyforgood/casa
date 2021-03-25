class ContactTypesController < ApplicationController
  before_action :set_contact_type, except: [:new, :create]
  after_action :verify_authorized

  def new
    authorize ContactType
    @contact_type = ContactType.new
  end

  def create
    authorize ContactType
    @contact_type = ContactType.new(contact_type_params)

    respond_to do |format|
      if @contact_type.save
        format.html { redirect_to edit_casa_org_path(current_organization), notice: "Contact Type was successfully created." }
      else
        format.html { render :new }
      end
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
      render :edit
    end
  end

  private

  def set_contact_type
    @contact_type = ContactType.find(params[:id])
  end

  def contact_type_params
    params.require(:contact_type).permit(:name, :contact_type_group_id, :active)
  end
end

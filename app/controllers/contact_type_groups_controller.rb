class ContactTypeGroupsController < ApplicationController
  before_action :set_contact_type_group, except: [:new, :create]
  after_action :verify_authorized

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def new
    authorize ContactTypeGroup
    @contact_type_group = ContactTypeGroup.new
  end

  def create
    authorize ContactTypeGroup
    @contact_type_group = ContactTypeGroup.new(contact_type_group_params.merge(casa_org: current_organization))

    if @contact_type_group.save
      redirect_to edit_casa_org_path(current_organization), notice: "Contact Type Group was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @contact_type_group
  end

  def update
    authorize @contact_type_group
    if @contact_type_group.update(contact_type_group_params)
      redirect_to edit_casa_org_path(current_organization), notice: "Contact Type Group was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def record_not_found
    respond_to do |format|
      format.json { render json: {error: "Record not found"}, status: :not_found }
      format.any { render file: Rails.public_path.join("404.html"), status: :not_found, layout: false }
    end
  end

  def contact_type_group_params
    params.require(:contact_type_group).permit(:name, :active)
  end

  def set_contact_type_group
    @contact_type_group = current_organization.contact_type_groups.find(params[:id])
  end
end

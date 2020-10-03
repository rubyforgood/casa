class ContactTypeGroupsController < ApplicationController
  before_action :authenticate_user!, :must_be_admin
  before_action :set_contact_type_group, except: [:new, :create]

  def new
    @contact_type_group = ContactTypeGroup.new
  end

  def create
    @contact_type_group = ContactTypeGroup.new(contact_type_group_params.merge(casa_org: current_organization))

    if @contact_type_group.save
      redirect_to edit_casa_org_path(current_organization), notice: "Contact Type Group was successfully created."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @contact_type_group.update(contact_type_group_params)
      redirect_to edit_casa_org_path(current_organization), notice: "Contact Type Group was successfully updated."
    else
      render :edit
    end
  end

  private

  def contact_type_group_params
    params.require(:contact_type_group).permit(:name, :active)
  end

  def set_contact_type_group
    @contact_type_group = ContactTypeGroup.find(params[:id])
  end
end

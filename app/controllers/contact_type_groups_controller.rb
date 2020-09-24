class ContactTypeGroupsController < ApplicationController
  before_action :must_be_admin

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

private

  def contact_type_group_params
    params.require(:contact_type_group).permit(:name)
  end
end

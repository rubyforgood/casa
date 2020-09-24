class ContactTypeGroupsController < ApplicationController
  before_action :must_be_admin

  def new
    @contact_type_group = ContactTypeGroup.new
  end

  def create
    @contact_type_group = ContactTypeGroup.new(contact_type_group_params.merge(casa_org: current_organization))

    respond_to do |format|
      if @contact_type_group.save
        format.html { redirect_to edit_casa_org_path(current_organization), notice: "Contact Type Group was successfully created." }
      else
        format.html { render :new }
      end
    end
  end

private

  def contact_type_group_params
    params.require(:contact_type_group).permit(:name)
  end
end

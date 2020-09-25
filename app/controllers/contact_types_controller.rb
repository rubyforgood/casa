class ContactTypesController < ApplicationController
  before_action :must_be_admin

  def new
    @contact_type = ContactType.new
    @group_options = ContactTypeGroup.for_organization(current_organization).collect { |group| [group.name, group.id] }
  end

  def create
    @contact_type = ContactType.new(contact_type_params)

    respond_to do |format|
      if @contact_type.save
        format.html { redirect_to edit_casa_org_path(current_organization), notice: "Contact Type was successfully created." }
      else
        format.html { render :new }
      end
    end
  end

private

  def contact_type_params
    params.require(:contact_type).permit(:name, :contact_type_group_id)
  end
end

class CustomOrgLinksController < ApplicationController
  before_action :set_custom_org_link, only: %i[edit update destroy]
  after_action :verify_authorized

  def new
    authorize CustomOrgLink
    @custom_org_link = CustomOrgLink.new
  end

  def create
    authorize CustomOrgLink

    if current_organization.custom_org_links.count >= CustomOrgLink::MAX_RECORDS_PER_ORG
      return redirect_to edit_casa_org_path(current_organization), alert: "Custom Link was not created - limit has been reached."
    end

    @custom_org_link = current_organization.custom_org_links.new(custom_org_link_params)

    if @custom_org_link.save
      redirect_to edit_casa_org_path(current_organization), notice: "Custom link was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @custom_org_link
  end

  def update
    authorize @custom_org_link
    if @custom_org_link.update(custom_org_link_params)
      redirect_to edit_casa_org_path(current_organization), notice: "Custom link was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @custom_org_link
    @custom_org_link.destroy
    redirect_to edit_casa_org_path(current_organization), notice: "Custom link was successfully deleted."
  end

  private

  def set_custom_org_link
    @custom_org_link = CustomOrgLink.find(params[:id])
  end

  def custom_org_link_params
    params.require(:custom_org_link).permit(:text, :url, :active)
  end
end

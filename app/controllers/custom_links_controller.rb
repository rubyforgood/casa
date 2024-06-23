class CustomLinksController < ApplicationController
  before_action :set_custom_link, only: %i[edit update soft_delete]

  # GET /custom_links/new
  def new
    authorize CustomLink
    custom_link = CustomLink.new(casa_org_id: current_user.casa_org_id)
    @custom_link = custom_link
  end

  # GET /custom_links/1/edit
  def edit
    authorize @custom_link
  end

  # POST /custom_links
  def create
    authorize CustomLink

    @custom_link = CustomLink.new(custom_link_params)

    if @custom_link.save
      redirect_to edit_casa_org_path(current_organization), notice: 'Custom link was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /custom_links/1
  def update
    authorize @custom_link
    if @custom_link.update(custom_link_params)
      redirect_to edit_casa_org_path(current_organization), notice: 'Custom link was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /contact_topics/1/soft_delete
  def soft_delete
    authorize @custom_link

    if @custom_link.update(soft_delete: true)
      redirect_to edit_casa_org_path(current_organization), notice: 'Custom link was successfully removed.'
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_custom_link
    @custom_link = CustomLink.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def custom_link_params
    params.require(:custom_link).permit(:text, :url, :active, :casa_org_id)
  end
end

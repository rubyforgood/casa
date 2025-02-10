class ContactTopicsController < ApplicationController
  before_action :set_contact_topic, only: %i[edit update soft_delete]
  after_action :verify_authorized

  # GET /contact_topics/new
  def new
    @contact_topic = ContactTopic.new(casa_org_id: current_user.casa_org_id)
    authorize @contact_topic
  end

  # GET /contact_topics/1/edit
  def edit
    authorize @contact_topic
  end

  # POST /contact_topics or /contact_topics.json
  def create
    @contact_topic = ContactTopic.new(contact_topic_params)
    authorize @contact_topic

    if @contact_topic.save
      redirect_to edit_casa_org_path(current_organization), notice: "Contact topic was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /contact_topics/1 or /contact_topics/1.json
  def update
    authorize @contact_topic

    if @contact_topic.update(contact_topic_params)
      redirect_to edit_casa_org_path(current_organization), notice: "Contact topic was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /contact_topics/1/soft_delete
  def soft_delete
    authorize @contact_topic

    if @contact_topic.update(soft_delete: true)
      redirect_to edit_casa_org_path(current_organization), notice: "Contact topic was successfully removed."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_contact_topic
    @contact_topic = ContactTopic.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def contact_topic_params
    params.require(:contact_topic).permit(:casa_org_id, :question, :details, :active)
  end
end

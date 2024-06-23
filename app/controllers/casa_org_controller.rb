class CasaOrgController < ApplicationController
  before_action :set_casa_org, only: %i[edit update]
  before_action :set_contact_type_data, only: %i[edit update]
  before_action :set_hearing_types, only: %i[edit update]
  before_action :set_judges, only: %i[edit update]
  before_action :set_learning_hour_types, only: %i[edit update]
  before_action :set_learning_hour_topics, only: %i[edit update]
  before_action :set_sent_emails, only: %i[edit update]
  before_action :set_contact_topics, only: %i[edit update]
  before_action :require_organization!
  after_action :verify_authorized
  before_action :set_active_storage_url_options, only: %i[edit update]

  def edit
    authorize @casa_org
  end

  def update
    authorize @casa_org

    if @casa_org.update(casa_org_update_params)
      respond_to do |format|
        format.html do
          redirect_to edit_casa_org_path, notice: "CASA organization was successfully updated."
        end

        format.json { render json: @casa_org, status: :ok }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: @casa_org.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_casa_org
    @casa_org = current_organization
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def casa_org_update_params
    params.require(:casa_org).permit(
      :name,
      :display_name,
      :address,
      :logo,
      :court_report_template,
      :show_driving_reimbursement,
      :additional_expenses_enabled,
      :other_duties_enabled,
      :twilio_account_sid,
      :twilio_phone_number,
      :twilio_api_key_sid,
      :twilio_api_key_secret,
      :twilio_enabled,
      :learning_topic_active
    )
  end

  def set_contact_type_data
    @contact_type_groups = @casa_org.contact_type_groups.order(:name)
    @contact_types = ContactType.for_organization(@casa_org).order(:name)
  end

  def set_hearing_types
    @hearing_types = HearingType.for_organization(@casa_org)
  end

  def set_judges
    @judges = Judge.for_organization(@casa_org)
  end

  def set_learning_hour_types
    @learning_hour_types = LearningHourType.for_organization(@casa_org)
  end

  def set_sent_emails
    @sent_emails = SentEmail.for_organization(@casa_org).order("created_at DESC").limit(10)
  end

  def set_learning_hour_topics
    @learning_hour_topics = LearningHourTopic.for_organization(@casa_org)
  end

  def set_contact_topics
    @contact_topics = @casa_org.contact_topics.where(soft_delete: false)
  end

  def set_custom_url
    @custom_links = @casa_org.custom_links.where(soft_delete: false)
  end

  def set_active_storage_url_options
    ActiveStorage::Current.url_options = {host: request.base_url}
  end
end

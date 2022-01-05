class CasaOrgController < ApplicationController
  before_action :set_casa_org, only: %i[edit update]
  before_action :set_contact_type_data, only: %i[edit update]
  before_action :set_hearing_types, only: %i[edit update]
  before_action :set_judges, only: %i[edit update]
  before_action :set_sent_emails, only: %i[edit update]
  before_action :require_organization!
  after_action :verify_authorized

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
      :show_driving_reimbursement
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

  def set_sent_emails
    @sent_emails = SentEmail.for_organization(@casa_org).order("created_at DESC").limit(10)
  end
end

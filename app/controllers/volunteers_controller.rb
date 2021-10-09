class VolunteersController < ApplicationController
  before_action :set_volunteer, except: %i[index new create datatable]
  after_action :verify_authorized

  def index
    authorize Volunteer
  end

  def datatable
    authorize Volunteer
    volunteers = policy_scope current_organization.volunteers
    datatable = VolunteerDatatable.new volunteers, params

    render json: datatable
  end

  def new
    authorize Volunteer
    @volunteer = Volunteer.new
  end

  def create
    authorize Volunteer
    @volunteer = Volunteer.new(create_volunteer_params)

    if @volunteer.save
      @volunteer.invite!(current_user)
      redirect_to edit_volunteer_path(@volunteer)
    else
      render :new
    end
  end

  def edit
    authorize @volunteer
    @supervisors = policy_scope current_organization.supervisors
  end

  def update
    authorize @volunteer
    if @volunteer.update(update_volunteer_params)
      redirect_to edit_volunteer_path(@volunteer), notice: "Volunteer was successfully updated."
    else
      render :edit
    end
  end

  def activate
    authorize @volunteer
    if @volunteer.activate
      VolunteerMailer.account_setup(@volunteer).deliver

      if (params[:redirect_to_path] == "casa_case") && (casa_case = CasaCase.find(params[:casa_case_id]))
        redirect_to edit_casa_case_path(casa_case), notice: "Volunteer was activated. They have been sent an email."
      else
        redirect_to edit_volunteer_path(@volunteer), notice: "Volunteer was activated. They have been sent an email."
      end
    else
      render :edit
    end
  end

  def deactivate
    authorize @volunteer
    if @volunteer.deactivate
      redirect_to edit_volunteer_path(@volunteer), notice: "Volunteer was deactivated."
    else
      render :edit
    end
  end

  def resend_invitation
    authorize @volunteer
    @volunteer = Volunteer.find(params[:id])
    if @volunteer.invitation_accepted_at.nil?
      @volunteer.invite!(current_user)
      redirect_to edit_volunteer_path(@volunteer), notice: "Invitation sent"
    else
      redirect_to edit_volunteer_path(@volunteer), notice: "User already accepted invitation"
    end
  end

  def reminder
    authorize @volunteer
    with_cc = params[:with_cc].present?

    cc_recipients = []
    if with_cc
      if current_user.casa_admin?
        cc_recipients.append(current_user.email)
      end
      cc_recipients.append(@volunteer.supervisor.email) if @volunteer.supervisor
    end
    VolunteerMailer.case_contacts_reminder(@volunteer, cc_recipients).deliver

    redirect_to edit_volunteer_path(@volunteer), notice: "Reminder sent to volunteer."
  end

  private

  def set_volunteer
    @volunteer = Volunteer.find(params[:id])
  end

  def generate_devise_password
    Devise.friendly_token.first(8)
  end

  def create_volunteer_params
    VolunteerParameters
      .new(params)
      .with_password(generate_devise_password)
      .without_active
  end

  def update_volunteer_params
    VolunteerParameters
      .new(params)
      .without_active
  end
end

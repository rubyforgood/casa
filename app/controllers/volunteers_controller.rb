class VolunteersController < ApplicationController
  before_action :set_volunteer, except: %i[index new create datatable stop_impersonating]
  after_action :verify_authorized, except: %i[stop_impersonating]

  def index
    authorize Volunteer
  end

  def show
    authorize @volunteer
    redirect_to action: :edit
  end

  def datatable
    authorize Volunteer
    volunteers = policy_scope current_organization.volunteers
    datatable = VolunteerDatatable.new volunteers, params

    render json: datatable
  end

  def new
    @volunteer = current_organization.volunteers.new
    authorize @volunteer
  end

  def create
    @volunteer = current_organization.volunteers.new(create_volunteer_params)
    authorize @volunteer

    if @volunteer.save
      @volunteer.invite!(current_user)
      notice_msg = send_sms @volunteer.phone_number
      redirect_to edit_volunteer_path(@volunteer), notice: notice_msg
    else
      render :new
    end
  end

  def edit
    authorize @volunteer
    @supervisors = policy_scope current_organization.supervisors.active
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

  def impersonate
    authorize @volunteer
    impersonate_user(@volunteer)
    redirect_to root_path
  end

  def stop_impersonating
    stop_impersonating_user
    redirect_to root_path
  end

  private

  # returns appropriate flash notice for SMS
  def send_sms(phone_number)
    if phone_number.blank?
      return "Volunteer created."
    end
    acc_sid = current_user.casa_org.twilio_account_sid
    api_key = current_user.casa_org.twilio_api_key_sid
    api_secret = current_user.casa_org.twilio_api_key_secret
    body = SMSNotifications::AccountActivation::BODY
    to = phone_number
    from = current_user.casa_org.twilio_phone_number

    twilio = TwilioService.new(api_key, api_secret, acc_sid)
    req_params = {
      From: from,
      Body: body,
      To: to
    }

    twilio_res = twilio.send_sms(req_params)
    if twilio_res.error_code === nil
      return "Volunteer created. SMS has been sent!"
    else
      return "Volunteer created. SMS not sent due to error."
    end
  end

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

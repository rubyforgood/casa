class VolunteersController < ApplicationController
  include SmsBodyHelper

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
      # call short io api here
      raw_token = @volunteer.raw_invitation_token
      invitation_url = Rails.application.routes.url_helpers.accept_user_invitation_url(invitation_token: raw_token, host: request.base_url)
      hash_of_short_urls = @volunteer.phone_number.blank? ? {0 => nil, 1 => nil} : handle_short_url([invitation_url, request.base_url + "/users/edit"])
      body_msg = account_activation_msg("volunteer", hash_of_short_urls)
      ###
      sms_status = deliver_sms_to @volunteer, body_msg # ##checks for twilio_enabled###
      ###
      redirect_to edit_volunteer_path(@volunteer), notice: sms_acct_creation_notice("volunteer", sms_status)
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
      notice = check_unconfirmed_email_notice(@volunteer)

      @volunteer.filter_old_emails!(@volunteer.email)
      redirect_to edit_volunteer_path(@volunteer), notice: notice
    else
      render :edit
    end
  end

  def activate
    authorize @volunteer
    if @volunteer.activate
      VolunteerMailer.account_setup(@volunteer).deliver

      if (params[:redirect_to_path] == "casa_case") && (casa_case = CasaCase.friendly.find(params[:casa_case_id]))
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

  def send_reactivation_alert
    authorize @volunteer
    if @volunteer.save
      begin
        send_sms_to(volunteers_phone_number, "Hello #{@volunteer.display_name}, \n \n Your CASA/Prince George’s County volunteer console account has been reactivated. You can login using the credentials you were already using. \n \n If you have any questions, please contact your most recent Case Supervisor for assistance. \n \n CASA/Prince George’s County")
        redirect_to edit_volunteer_path(@volunteer), notice: "Volunteer reactivation alert sent"
      rescue StandardError => error
        if error.kind_of? NoMethodError #Most likely unverified phone number
          redirect_to edit_volunteer_path(@volunteer), notice: "SMS Not Sent. Volunteer Phone Number is not verified."
        else 
        redirect_to edit_volunteer_path(@volunteer), notice: "Volunteer reactivation alert not sent. #{error}"
        end 
      end
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

  def volunteers_phone_number
    authorize @volunteer
    @volunteers_phone_number = @volunteer.phone_number
  end

  def send_sms_to(phone_number, body)
    twilio = TwilioService.new(current_user.casa_org)
    req_params = {From: current_user.casa_org.twilio_phone_number, Body: body, To: phone_number}
    twilio_res = twilio.send_sms(req_params)

    # Error handling for spec test purposes
    if twilio_res.error_code.nil?
      "SMS has been sent to Volunteer!"
    else
      "SMS was not sent to Volunteer due to an error."
    end
  end
end

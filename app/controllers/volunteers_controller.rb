class VolunteersController < ApplicationController
  include SmsBodyHelper

  PER_PAGE = 25

  before_action :set_volunteer, except: %i[index new create stop_impersonating]
  before_action :set_edit_context, only: %i[edit update activate deactivate]
  after_action :verify_authorized, except: %i[stop_impersonating]

  def index
    authorize Volunteer
    @active_nav = "volunteers"
    @supervisors = policy_scope(current_organization.supervisors.active)
    set_index_filters
    load_paginated_volunteers
    render :index, layout: "casa_app"
  end

  def show
    authorize @volunteer
    redirect_to action: :edit
  end

  def new
    @volunteer = current_organization.volunteers.new
    authorize @volunteer
    @active_nav = "volunteers"
    render layout: "casa_app"
  end

  def create
    @volunteer = current_organization.volunteers.new(create_volunteer_params)
    authorize @volunteer

    unless @volunteer.save
      @active_nav = "volunteers"
      return render :new, status: :unprocessable_content, layout: "casa_app"
    end

    invite_volunteer
    sms_status = deliver_sms_to @volunteer, account_activation_msg("volunteer", activation_short_urls)
    redirect_to edit_volunteer_path(@volunteer), notice: sms_acct_creation_notice("volunteer", sms_status)
  end

  def edit
    authorize @volunteer
    render layout: "casa_app"
  end

  def update
    authorize @volunteer
    skip_volunteer_email_reconfirmation

    if @volunteer.update(update_volunteer_params)
      notice = check_unconfirmed_email_notice(@volunteer)

      @volunteer.filter_old_emails!(@volunteer.email)
      redirect_to edit_volunteer_path(@volunteer), notice: notice
    else
      render :edit, status: :unprocessable_content, layout: "casa_app"
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
      render :edit, status: :unprocessable_content, layout: "casa_app"
    end
  end

  def deactivate
    authorize @volunteer
    if @volunteer.deactivate
      redirect_to edit_volunteer_path(@volunteer), notice: "Volunteer was deactivated."
    else
      render :edit, status: :unprocessable_content, layout: "casa_app"
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
        send_sms_to(volunteers_phone_number, volunteer_reactivation_msg(@volunteer.display_name))
        redirect_to edit_volunteer_path(@volunteer), notice: "Volunteer reactivation alert sent"
      rescue
        redirect_to edit_volunteer_path(@volunteer), notice: "Volunteer reactivation alert not sent. Twilio is disabled for #{@volunteer.casa_org.name}."
      end
    end
  end

  def reminder
    authorize @volunteer
    VolunteerMailer.case_contacts_reminder(@volunteer, reminder_cc_recipients).deliver

    redirect_back_or_to edit_volunteer_path(@volunteer), notice: "Reminder sent to volunteer."
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

  # A failed invitation must not fail the creation itself — the volunteer record is already saved,
  # so surface the reason and carry on to the activation SMS.
  def invite_volunteer
    @volunteer.invite!(current_user)
  rescue => e
    flash[:alert] = "Volunteer invitation failed. Reason: #{e.message}"
  end

  # The two links the activation SMS shortens (via short.io): set-password and profile-edit. Only
  # shortened when there is a phone number to text; otherwise account_activation_msg falls back to
  # its "check your email" wording.
  def activation_short_urls
    return {0 => nil, 1 => nil} if @volunteer.phone_number.blank?

    handle_short_url([accept_invitation_url, "#{request.base_url}/users/edit"])
  end

  def accept_invitation_url
    Rails.application.routes.url_helpers.accept_user_invitation_url(
      invitation_token: @volunteer.raw_invitation_token,
      host: request.base_url
    )
  end

  # An admin sending the reminder is cc'd on it; a supervisor is not (they are cc'd only as the
  # volunteer's own supervisor, which the second line covers for admins and supervisors alike).
  def reminder_cc_recipients
    return [] if params[:with_cc].blank?

    recipients = []
    recipients.append(current_user.email) if current_user.casa_admin?
    recipients.append(@volunteer.supervisor.email) if @volunteer.supervisor
    recipients
  end

  # Shared setup for the actions that render the casa_app edit page (edit + the
  # update/activate/deactivate failure re-renders): light up the sidebar nav and
  # load the active supervisors the "assign a supervisor" form needs.
  def set_edit_context
    @active_nav = "volunteers"
    @supervisors = policy_scope current_organization.supervisors.active
  end

  # The index view and its _filter partial read these ivars directly, the same convention the
  # other Tailwind index pages (supervisors, casa_cases) use for sortable_header, so mirror the
  # normalized values from the filter object onto them.
  def set_index_filters
    @filters = VolunteerIndexFilters.new(params, supervisor_ids: @supervisors.map { |s| s.id.to_s })
    @search = @filters.search
    @status = @filters.status
    @supervisor_filter = @filters.supervisor
    @transition = @filters.transition
    @extra_languages = @filters.extra_languages
    @sort = @filters.sort
    @direction = @filters.direction
  end

  def load_paginated_volunteers
    datatable = VolunteerDatatable.new(policy_scope(current_organization.volunteers), @filters.to_datatable_params)
    count = datatable.index_count
    page = params[:page].to_i.clamp(1, [(count.to_f / PER_PAGE).ceil, 1].max)
    @pagy = Pagy.new(count: count, page: page, limit: PER_PAGE)
    @volunteers = datatable.index_relation.offset(@pagy.offset).limit(PER_PAGE).to_a
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

  def skip_volunteer_email_reconfirmation
    return if update_volunteer_params[:email].blank?
    return if update_volunteer_params[:email] == @volunteer.email

    @volunteer.skip_reconfirmation!
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

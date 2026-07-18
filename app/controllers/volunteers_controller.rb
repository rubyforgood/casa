class VolunteersController < ApplicationController
  include SmsBodyHelper

  before_action :set_volunteer, except: %i[index new create datatable stop_impersonating]
  before_action :set_edit_context, only: %i[edit update activate deactivate]
  after_action :verify_authorized, except: %i[stop_impersonating]

  def index
    authorize Volunteer
    @active_nav = "volunteers"
    @supervisors = policy_scope(current_organization.supervisors.active)
    @search = params[:search].to_s
    @status = %w[active inactive all].include?(params[:status]) ? params[:status] : "active"
    @supervisor_filter = params[:supervisor].to_s
    @transition = %w[yes no].include?(params[:transition]) ? params[:transition] : ""
    @extra_languages = %w[yes no].include?(params[:languages]) ? params[:languages] : ""
    @sort = VolunteerDatatable::ORDERABLE_FIELDS.include?(params[:sort]) ? params[:sort] : "display_name"
    @direction = (params[:direction] == "desc") ? "desc" : "asc"

    datatable = VolunteerDatatable.new(policy_scope(current_organization.volunteers), volunteer_index_params)
    count = datatable.index_count
    per_page = 25
    page = params[:page].to_i.clamp(1, [(count.to_f / per_page).ceil, 1].max)
    @pagy = Pagy.new(count: count, page: page, limit: per_page)
    @volunteers = datatable.index_relation.offset(@pagy.offset).limit(per_page).to_a
    render :index, layout: "casa_app"
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
      # invitation error handling
      begin
        @volunteer.invite!(current_user)
      rescue => e
        flash[:alert] = "Volunteer invitation failed. Reason: #{e.message}"
      end

      # call short io api here
      invitation_url = Rails.application.routes.url_helpers.accept_user_invitation_url(invitation_token: @volunteer.raw_invitation_token, host: request.base_url)

      hash_of_short_urls = {0 => nil, 1 => nil}
      if @volunteer.phone_number.present?
        hash_of_short_urls = handle_short_url([invitation_url, request.base_url + "/users/edit"])
      end

      sms_status = deliver_sms_to @volunteer, account_activation_msg("volunteer", hash_of_short_urls)
      redirect_to edit_volunteer_path(@volunteer), notice: sms_acct_creation_notice("volunteer", sms_status)
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @volunteer
    render layout: "casa_app"
  end

  def update
    authorize @volunteer
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
        send_sms_to(volunteers_phone_number, "Hello #{@volunteer.display_name}, \n \n Your CASA/Prince George’s County volunteer console account has been reactivated. You can login using the credentials you were already using. \n \n If you have any questions, please contact your most recent Case Supervisor for assistance. \n \n CASA/Prince George’s County")
        redirect_to edit_volunteer_path(@volunteer), notice: "Volunteer reactivation alert sent"
      rescue
        redirect_to edit_volunteer_path(@volunteer), notice: "Volunteer reactivation alert not sent. Twilio is disabled for #{@volunteer.casa_org.name}."
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

  # Shared setup for the actions that render the casa_app edit page (edit + the
  # update/activate/deactivate failure re-renders): light up the sidebar nav and
  # load the active supervisors the "assign a supervisor" form needs.
  def set_edit_context
    @active_nav = "volunteers"
    @supervisors = policy_scope current_organization.supervisors.active
  end

  # Map the index's plain GET filters into the DataTables param shape VolunteerDatatable
  # understands, so the migrated (bespoke Pagy) index reuses its exact filter/search/order SQL.
  def volunteer_index_params
    {
      search: {value: @search},
      additional_filters: {
        active: volunteer_active_filter,
        supervisor: volunteer_supervisor_filter,
        transition_aged_youth: (@transition.present? ? [(@transition == "yes").to_s] : %w[true false]),
        extra_languages: (@extra_languages.present? ? [(@extra_languages == "yes").to_s] : nil)
      },
      columns: {"0" => {name: @sort}},
      order: {"0" => {column: "0", dir: @direction}}
    }.with_indifferent_access
  end

  def volunteer_active_filter
    case @status
    when "inactive" then %w[false]
    when "all" then %w[true false]
    else %w[true]
    end
  end

  # The datatable's supervisor filter is value-list based: [""] means "no supervisor", a list of
  # ids means those supervisors, and "" mixed with ids means "null OR those". "All" therefore
  # passes "" + every active supervisor id so it also includes volunteers whose supervisor is
  # inactive/absent (their joined supervisor is null).
  def volunteer_supervisor_filter
    case @supervisor_filter
    when "", "all" then ["", *@supervisors.map { |s| s.id.to_s }]
    when "unassigned" then [""]
    else [@supervisor_filter]
    end
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

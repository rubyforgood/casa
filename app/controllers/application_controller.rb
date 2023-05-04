class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Organizational

  protect_from_forgery
  before_action :store_user_location!, if: :storable_location?
  before_action :authenticate_user!
  before_action :set_current_user
  before_action :set_current_organization
  after_action :verify_authorized, except: :index, unless: :devise_controller?
  # after_action :verify_policy_scoped, only: :index

  rescue_from Pundit::NotAuthorizedError, with: :not_authorized
  rescue_from Organizational::UnknownOrganization, with: :not_authorized

  impersonates :user

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || super
  end

  def after_sign_out_path_for(resource_or_scope)
    session[:user_return_to] = nil
    if resource_or_scope == :all_casa_admin
      new_all_casa_admin_session_path
    else
      root_path
    end
  end

  protected

  def handle_short_url(url_list)
    hash_of_short_urls = {}
    url_list.each_with_index { |val, index|
      # call short io service to shorten url
      # create an entry in hash if api is success
      short_io_service = ShortUrlService.new
      response = short_io_service.create_short_url(val)
      short_url = short_io_service.short_url
      hash_of_short_urls[index] = response.code == 201 || response.code == 200 ? short_url : nil
    }
    hash_of_short_urls
  end

  # volunteer/supervisor/casa_admin controller uses to send SMS
  # returns appropriate flash notice for SMS
  def deliver_sms_to(resource, body_msg)
    if resource.phone_number.blank?
      return "blank"
    end
    acc_sid = current_user.casa_org.twilio_account_sid
    api_key = current_user.casa_org.twilio_api_key_sid
    api_secret = current_user.casa_org.twilio_api_key_secret
    body = body_msg
    to = resource.phone_number
    from = current_user.casa_org.twilio_phone_number

    twilio = TwilioService.new(api_key, api_secret, acc_sid)
    req_params = {
      From: from,
      Body: body,
      To: to
    }

    begin
      twilio_res = twilio.send_sms(req_params)
      twilio_res.error_code.nil? ? "sent" : "error"
    rescue Twilio::REST::RestError
      "error"
    end
  end

  def sms_acct_creation_notice(resource_name, sms_status)
    if sms_status === "blank"
      return "New #{resource_name} created successfully."
    end
    if sms_status === "error"
      return "New #{resource_name} created successfully. SMS not sent due to error."
    end
    if sms_status === "sent"
      "New #{resource_name} created successfully. SMS has been sent!"
    end
  end

  private

  def store_user_location!
    # the current URL can be accessed from a session
    store_location_for(:user, request.fullpath)
  end

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def set_current_user
    RequestStore.store[:current_user] = current_user
  end

  def set_current_organization
    RequestStore.store[:current_organization] = current_organization
  end

  def not_authorized
    session[:user_return_to] = nil
    flash[:notice] = "Sorry, you are not authorized to perform this action."
    redirect_to(root_url)
  end

  def admin_email_change(user) #for casa admins
    if user.saved_changes.include?("unconfirmed_email")
      redirect_to edit_polymorphic_path(user), notice: "Confirmation Email Sent To #{user.role}."
    end
  end

  def all_casa_admin_email_change(user, casa_org) #for all casa admins
    if user.saved_changes.include?("unconfirmed_email")
      redirect_to edit_all_casa_admins_casa_org_casa_admin_path(casa_org), notice: "Confirmation Email Sent To Casa Admin."
    end
  end
end

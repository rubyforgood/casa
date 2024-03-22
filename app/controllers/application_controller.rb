class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Organizational
  include Users::TimeZone

  protect_from_forgery
  before_action :remove_www_subdomain
  before_action :store_user_location!, if: :storable_location?
  before_action :authenticate_user!
  before_action :set_current_user
  before_action :set_timeout_duration
  before_action :set_current_organization
  before_action :set_active_banner
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

  def set_active_banner
    return nil unless current_organization

    @active_banner = current_organization.banners.active.first
    @active_banner = nil if session[:dismissed_banner] == @active_banner&.id
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
      hash_of_short_urls[index] = (response.code == 201 || response.code == 200) ? short_url : nil
    }
    hash_of_short_urls
  end

  # volunteer/supervisor/casa_admin controller uses to send SMS
  # returns appropriate flash notice for SMS
  def deliver_sms_to(resource, body_msg)
    if resource.phone_number.blank? || !resource.casa_org.twilio_enabled?
      return "blank"
    end

    body = body_msg
    to = resource.phone_number
    from = current_user.casa_org.twilio_phone_number

    @twilio = TwilioService.new(current_user.casa_org)
    req_params = {
      From: from,
      Body: body,
      To: to
    }

    begin
      twilio_res = @twilio.send_sms(req_params)
      twilio_res.error_code.nil? ? "sent" : "error"
    rescue Twilio::REST::RestError => error
      @error = error
      "error"
    rescue # unverfied error isnt picked up by Twilio::Rest::RestError
      # https://www.twilio.com/docs/errors/21608
      @error = "Phone number is unverifiied"
      "error"
    end
  end

  def sms_acct_creation_notice(resource_name, sms_status)
    case sms_status
    when "blank"
      "New #{resource_name} created successfully."
    when "error"
      "New #{resource_name} created successfully. SMS not sent. Error: #{@error}."
    when "sent"
      "New #{resource_name} created successfully. SMS has been sent!"
    end
  end

  def store_referring_location
    session[:return_to] = request.referer
  end

  def redirect_back_to_referer(fallback_location:)
    redirect_to(session[:return_to] || fallback_location)
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

  def set_timeout_duration
    return unless current_user

    @timeout_duration = current_user.timeout_in
  end

  def set_current_organization
    RequestStore.store[:current_organization] = current_organization
  end

  def not_authorized
    session[:user_return_to] = nil
    flash[:notice] = "Sorry, you are not authorized to perform this action."
    redirect_to(root_url)
  end

  def check_unconfirmed_email_notice(user)
    notice = "#{user.role} was successfully updated."
    if user.saved_changes.include?("unconfirmed_email")
      notice += " Confirmation Email Sent."
    end
    notice
  end

  def remove_www_subdomain
    if /^www/.match?(request.host)
      redirect_to request.url.sub("www.", ""), allow_other_host: true
    end
  end
end

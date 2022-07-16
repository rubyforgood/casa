class Users::PasswordsController < Devise::PasswordsController
  include ApplicationHelper
  include PhoneNumberHelper
  include SmsBodyHelper

  def create
    email = params[resource_name][:email]
    phone_number = params[resource_name][:phone_number]
    reset_token = nil
    @resource = email.blank? ? User.find_by(phone_number: phone_number) : User.find_by(email: email)

    # re-render and display any errors
    params_is_valid, error_resource = password_params_is_valid(resource, email, phone_number)
    if !params_is_valid
      respond_with(error_resource)
      return
    end

    # generate a reset token and
    # call devise mailer
    if !email.blank?
      reset_token = @resource.send_reset_password_instructions
    end

    if !phone_number.blank?
      # when user enters ONLY a phone number, generate a new reset token to use;
      # otherwise, use the same reset token as sent by devise mailer
      reset_token ||= @resource.generate_password_reset_token

      reset_password_link = request.base_url + "/users/password/edit?reset_password_token=#{reset_token}"
      short_io_service = ShortUrlService.new
      twilio_service = TwilioService.new(@resource.casa_org.twilio_api_key_sid, @resource.casa_org.twilio_api_key_secret, @resource.casa_org.twilio_account_sid)

      short_io_service.create_short_url(reset_password_link)
      body_msg = password_reset_msg(@resource.display_name, short_io_service.short_url)

      sms_params = {
        From: @resource.casa_org.twilio_phone_number,
        Body: body_msg,
        To: phone_number
      }
      twilio_service.send_sms(sms_params)
    end

    redirect_to after_sending_reset_password_instructions_path_for(resource_name), notice: "You will receive an email or SMS with instructions on how to reset your password in a few minutes."
  end

  private

  def password_params_is_valid(resource, email, phone_number)
    if email.blank? && phone_number.blank? && resource
      resource.errors.add(:base, "Please enter at least one field.")
      return [false, resource]
    end

    phone_number_is_valid, error_message = valid_phone_number(phone_number)
    if !phone_number_is_valid && resource
      resource.errors.add(:phone_number, error_message)
      return [false, resource]
    end

    if resource.email != email || resource.phone_number != phone_number
      # A new, empty resource is returned (see application helper)
      # so to check for nil, we need to check its email/phone fields
      resource.errors.add(:base, "User does not exist.")
      return [false, resource]
    end
    [true, nil]
  end
end

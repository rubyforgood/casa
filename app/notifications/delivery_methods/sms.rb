class DeliveryMethods::Sms < Noticed::DeliveryMethods::Base
  def deliver
    twilio = TwilioService.new(recipient.casa_org.twilio_api_key_sid, recipient.casa_org.twilio_api_key_secret, recipient.casa_org.twilio_account_sid)

    short_io_main = ShortUrlService.new
    short_io_main.create_short_url(url)
    shortened_url = short_io_main.short_url

    req_params = {From: recipient.casa_org.twilio_phone_number, Body: "-\n \n#{supervisor_or_admin_display_name} has flagged a Case Contact that needs follow up. Click to see more: #{shortened_url}", To: recipient.phone_number}
    twilio_res = twilio.send_sms(req_params)
  end

  def url
    Rails.application.credentials[:BASE_URL] + "/case_contacts/" + case_contact_id.to_s + "/edit"
  end

  private

  def supervisor_or_admin_display_name
    params[:created_by][:display_name]
  end

  def case_contact_id
    params[:followup][:case_contact_id]
  end

  # You may override this method to validate options for the delivery method
  # Invalid options should raise a ValidationError
  #
  # def self.validate!(options)
  #   raise ValidationError, "required_option missing" unless options[:required_option]
  # end
end

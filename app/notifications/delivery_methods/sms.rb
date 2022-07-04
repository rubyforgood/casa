class DeliveryMethods::Sms < Noticed::DeliveryMethods::Base
  def deliver
    twilio = TwilioService.new(recipient.casa_org.twilio_api_key_sid, recipient.casa_org.twilio_api_key_secret, recipient.casa_org.twilio_account_sid)
    req_params = {From: recipient.casa_org.twilio_phone_number, Body: "-\n \n[supervisor/admin name] has flagged a Case Contact that needs follow up. Click to see more: [link]", To: recipient.phone_number}
    twilio_res = twilio.send_sms(req_params)
  end

  # You may override this method to validate options for the delivery method
  # Invalid options should raise a ValidationError
  #
  # def self.validate!(options)
  #   raise ValidationError, "required_option missing" unless options[:required_option]
  # end
end

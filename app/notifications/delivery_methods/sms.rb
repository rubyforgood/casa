class DeliveryMethods::Sms < Noticed::DeliveryMethods::Base
  def deliver
    twilio = TwilioService.new(recipient.casa_org.twilio_api_key_sid, recipient.casa_org.twilio_api_key_secret, recipient.casa_org.twilio_account_sid)
  end

  # You may override this method to validate options for the delivery method
  # Invalid options should raise a ValidationError
  #
  # def self.validate!(options)
  #   raise ValidationError, "required_option missing" unless options[:required_option]
  # end
end

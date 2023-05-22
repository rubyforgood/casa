class DeliveryMethods::Sms < Noticed::DeliveryMethods::Base
  include SmsBodyHelper
  def deliver
    if sender.casa_org.twilio_enabled? && (sender.casa_admin? || sender.supervisor?)
      short_io_api = ShortUrlService.new
      short_io_api.create_short_url(case_contact_url)
      shortened_url = short_io_api.short_url
      if sender.casa_org.twilio_enabled?
        twilio_api = TwilioService.new(sender.casa_org.twilio_api_key_sid, sender.casa_org.twilio_api_key_secret, sender.casa_org.twilio_account_sid)
        twilio_api.send_sms({From: sender.casa_org.twilio_phone_number, Body: case_contact_flagged_msg(sender.display_name, shortened_url), To: recipient.phone_number})
      else
        flash[:notice] = "SMS notice was not sent. Twilio is not Enabled."
      end
    end
  end

  def case_contact_url
    Rails.application.credentials[:BASE_URL] + "/case_contacts/" + case_contact_id.to_s + "/edit?notification_id=" + record.id.to_s
  end

  private

  def sender
    User.find(params[:followup][:creator_id])
  end

  def case_contact_id
    params[:followup][:case_contact_id]
  end
end

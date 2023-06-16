require "json"
require "twilio-ruby"

class TwilioService
  attr_writer :api_key, :api_secret, :acc_sid, :casa_org

  def initialize(casa_org)
    @api_key = casa_org.twilio_api_key_sid
    @api_secret = casa_org.twilio_api_key_secret
    @acc_sid = casa_org.twilio_account_sid
    @enabled = casa_org.twilio_enabled
  end

  def client # lazy create client only if twilio enabled
    @client = Twilio::REST::Client.new(@api_key, @api_secret, @acc_sid)
  end

  def enabled?
    @enabled
  end

  # this method takes in a hash
  # required keys are: From:, To:, Body:
  # to send a short url, set URL: key in hash
  def send_sms(params)
    if !enabled?
      return nil
    end

    from = params[:From]
    body = params.key?(:URL) ? params[:Body] + params[:URL] : params[:Body]
    to = params[:To]
    # returns a twilio API message object
    # refer to docs: https://www.twilio.com/docs/sms/api/message-resource#message-properties
    begin
      client
      client.messages.create(
        from: from,
        body: body,
        to: to
      )
    rescue => error
      Rails.logger.error("send SMS failed: #{error}")
      error
    end
  end
end

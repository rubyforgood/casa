require "json"
require "twilio-ruby"

class TwilioService
  attr_writer :api_key, :api_secret, :acc_sid

  def initialize(api_key, api_secret, acc_sid)
    @api_key = api_key
    @api_secret = api_secret
    @acc_sid = acc_sid
    @client = Twilio::REST::Client.new(api_key, api_secret, acc_sid)
  end

  # this method takes in a hash
  # required keys are: From:, To:, Body:
  # to send a short url, set URL: key in hash
  def send_sms(params)
    from = params[:From]
    body = params.key?(:URL) ? params[:Body] + params[:URL] : params[:Body]
    to = params[:To]
    # returns a twilio API message object
    # refer to docs: https://www.twilio.com/docs/sms/api/message-resource#message-properties
    begin
      @client.messages.create(
        from: from,
        body: body,
        to: to
      )
    rescue => e
      Rails.logger.error("send SMS failed: #{e}")
    end
  end
end

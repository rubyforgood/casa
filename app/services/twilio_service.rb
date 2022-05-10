require "twilio-ruby"
require "json"

class TwilioService
  def initialize(api_key, api_secret, acc_sid)
    @api_key = api_key
    @api_secret = api_secret
    @acc_sid = acc_sid
    @client = Twilio::REST::Client.new(api_key, api_secret, acc_sid)
  end

  # this method takes in a hash
  # required keys are: From:, To:, Body:
  # to send a short url, use URL: key in hash
  def send_sms(params)
    from = params[:From]
    body = params.key?(:URL) ? params[:Body] + params[:URL] : params[:Body]
    to = params[:To]
    # returns a twilio API message object
    # refer: https://www.twilio.com/docs/sms/api/message-resource#message-properties
    message = @client.messages.create(
      from: from,
      body: body,
      to: to,
    )
  end

  def get_acc_sid()
    @acc_sid
  end

  def get_api_key()
    @api_key
  end

  def get_api_secret()
    @api_secret
  end
end

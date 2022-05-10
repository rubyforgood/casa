require "twilio-ruby"
require "json"

class TwilioService
  def initialize(api_key, api_secret, acc_sid)
    @api_key = api_key
    @api_secret = api_secret
    @acc_sid = acc_sid
    @client = Twilio::REST::Client.new(api_key, api_secret, acc_sid)
  end

  def send_sms(params)
    # line 14 returns a twilio API message object
    message = @client.messages.create(
      from: params[:From],
      body: params[:Body],
      to: params[:To],
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

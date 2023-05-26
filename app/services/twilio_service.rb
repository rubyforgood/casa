require "json"
require "twilio-ruby"

class TwilioService # just a plain ol regular ruby class
  class TwilioCasaOrgError < StandardError; end # metaprogramming, within the scope, thats where we want to define this
  attr_writer :api_key, :api_secret, :acc_sid, :casa_org

  # def new
  # overwrite .new for this class, get the client, if not return nil/error
  # super?
  # end

  def initialize(casa_org) # api_key, api_secret, acc_sid, this is getting called during new, poro!
    # this must have a casa_org passed into it!
    # dont pass this line unless good to go, fail early!!!
    # this error gets raised, but
    raise TwilioCasaOrgError.new "Twilio not enabled for #{casa_org.name}" unless casa_org.twilio_enabled?

    @api_key = casa_org.twilio_api_key_sid
    @api_secret = casa_org.twilio_api_key_secret
    @acc_sid = casa_org.twilio_account_sid

    # custom error message here!!! StandardError
    @client = Twilio::REST::Client.new(@api_key, @api_secret, @acc_sid)
    # failing gracefully,
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

require "json"
require "twilio-ruby"

class TwilioService
  class TwilioCasaOrgError < StandardError; end
  attr_writer :api_key, :api_secret, :acc_sid, :casa_org

  def initialize(casa_org)
    #if or lazily create, not exceptional! they are slower than conditonal, 
    # eliminating 
    raise TwilioCasaOrgError.new "Twilio is disabled for #{casa_org.name}" unless casa_org.twilio_enabled? #this makes it hard to test in isolation

    @api_key = casa_org.twilio_api_key_sid
    @api_secret = casa_org.twilio_api_key_secret
    @acc_sid = casa_org.twilio_account_sid

    #@client = Twilio::REST::Client.new(@api_key, @api_secret, @acc_sid)
  end

  def client
    @client ||= Twilio::REST::Client.new(@api_key, @api_secret, @acc_sid)
  end 

  def enabled? 
    #as long as casa_org twilio check 
  end 
  # this method takes in a hash
  # required keys are: From:, To:, Body:
  # to send a short url, set URL: key in hash
  def send_sms(params)
    #return unless casa_org twilio enabled
    #add check here, Twilio client
    from = params[:From]
    body = params.key?(:URL) ? params[:Body] + params[:URL] : params[:Body]
    to = params[:To]
    # returns a twilio API message object
    # refer to docs: https://www.twilio.com/docs/sms/api/message-resource#message-properties
    begin
      #clientMethod.create if you ever get here, then it would create (i.e. lazy create)
      @client.messages.create(
        from: from,
        body: body,
        to: to
      )
    rescue => error
      Rails.logger.error("send SMS failed: #{error}") #help a person know whats going on, these messages can be inspected (Twilio)
      error
    end
  end
end

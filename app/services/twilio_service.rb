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

    return sms_preview(from, body, to) if Rails.env.development?
    @client.messages.create(
      from: from,
      body: body,
      to: to
    )
  end

  def sms_preview(from, body, to)
    tmp_dir = Dir.mktmpdir
    file_path = File.join(tmp_dir, "#{SecureRandom.uuid}.html")
    File.open(file_path, "w") do |file|
      template = ERB.new(<<-TEMPLATE)
      <html>
      <head><title>SMS Preview</title></head>
      <body>
      <center><h1>SMS Preview</h1></center>
      <p>#{body}</p>
      </body>
      </html>
      TEMPLATE
      file.write(template.result(binding))
    end
    Launchy.open(file_path)
  end
end

require "support/stubbed_requests/short_io_api"
require "support/stubbed_requests/twilio_api"

class WebMockHelper
  extend ShortIOAPI
  extend TwilioAPI
end

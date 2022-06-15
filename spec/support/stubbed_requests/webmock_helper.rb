require "support/stubbed_requests/short_io_api"
require "support/stubbed_requests/twilio_api"

class WebMockHelper
  extend ShortIOAPI
  extend TwilioAPI

  def initialize(blacklist)
    @blacklist = blacklist
  end

  def stub_network_connection
    WebMock.disable_net_connect!(allow: allowed_sites)
  end

  private

  def allowed_sites
    lambda { |uri|
      @blacklist.none? { |site| uri.host.include?(site) }
    }
  end
end

require "rails_helper"
require "support/stubbed_requests/webmock_helper"

RSpec.describe "/users/passwords", type: :request do
  describe "POST /create" do
    before do
      stubbed_sites = ["api.twilio.com", "api.short.io"]
      web_mock = WebMockHelper.new(stubbed_sites)
      web_mock.stub_network_connection
    end

    it "sends a password reset SMS to existing user" do
      org = create(:casa_org)
      user = create(:user, phone_number: "+12222222222", casa_org: org)

      @short_io_stub = WebMockHelper.short_io_stub_sms
      @twilio_stub = WebMockHelper.twilio_password_reset_stub(user)

      params = {
        user: {
          email: user.email,
          phone_number: user.phone_number
        }
      }

      post "/users/password", params: params
      expect(@short_io_stub).to have_been_requested.times(1)
      expect(@twilio_stub).to have_been_requested.times(1)
      expect(response).to have_http_status(:redirect)
      follow_redirect!
      expect(flash[:notice]).to match(/You will receive an email or SMS with instructions on how to reset your password in a few minutes./)
    end
  end
end

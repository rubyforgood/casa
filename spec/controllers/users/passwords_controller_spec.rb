require "rails_helper"
require "support/stubbed_requests/webmock_helper"

RSpec.describe Users::PasswordsController, type: :controller do
  describe "create" do
    before do
      stubbed_sites = ["api.twilio.com", "api.short.io"]
      web_mock = WebMockHelper.new(stubbed_sites)
      web_mock.stub_network_connection
    end

    context "when parameters are provided" do
      let!(:org) { create(:casa_org) }
      let!(:user) { create(:user, phone_number: "+12222222222", casa_org: org) }
      let!(:user_phone_param) { {user: {email: "", phone_number: user.phone_number}} }
      let!(:user_email_param) { {user: {email: user.email, phone_number: ""}} }
      let!(:user_params) { {user: {email: user.email, phone_number: user.phone_number}} }
      let!(:short_io_stub) { WebMockHelper.short_io_stub_sms }
      let!(:twilio_stub) { WebMockHelper.twilio_password_reset_stub(user) }

      context "when email and phone are provided" do
        it "sends a password reset SMS to existing user" do
          post :create, params: user_params
          expect(short_io_stub).to have_been_requested.times(1)
          expect(twilio_stub).to have_been_requested.times(1)
          expect(response).to have_http_status(:redirect)
        end
      end

      context "when only phone is provided" do
        it "sends a password reset SMS to existing user" do
          post :create, params: user_phone_param
          expect(short_io_stub).to have_been_requested.times(1)
          expect(twilio_stub).to have_been_requested.times(1)
          expect(response).to have_http_status(:redirect)
        end
      end

      context "when only email is provided" do
        it "sends a password reset email to existing user" do
          post :create, params: user_email_param
          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end
    end

    context "when parameters are not provided" do
      let!(:org) { create(:casa_org) }
      let!(:user) { create(:user, phone_number: "+12222222223", casa_org: org) }
      let!(:no_params) { {user: {email: "", phone_number: ""}} }

      it "does not send sms with reset password" do
        short_io_stub = WebMockHelper.short_io_stub_sms
        twilio_stub = WebMockHelper.twilio_password_reset_stub(user)

        post :create, params: no_params
        expect(short_io_stub).to have_been_requested.times(0)
        expect(twilio_stub).to have_been_requested.times(0)
      end

      it "does not send email with reset password" do
        post :create, params: no_params
        expect(ActionMailer::Base.deliveries.count).to eq(0)
      end
    end
  end
end

require "rails_helper"

RSpec.describe "Users::PasswordsController", type: :request do
  let!(:org) { create(:casa_org) }
  let!(:user) { create(:user, phone_number: "+12222222222", casa_org: org) }

  let!(:twilio_service_double) { instance_double(TwilioService) }
  let!(:short_url_service_double) { instance_double(ShortUrlService) }

  before do
    allow(TwilioService).to(
      receive(:new).with(
        org
      ).and_return(twilio_service_double)
    )

    allow(twilio_service_double).to receive(:send_sms)

    allow(ShortUrlService).to receive(:new).and_return(short_url_service_double)

    allow(short_url_service_double).to(
      receive(:create_short_url).with(a_string_matching(edit_user_password_path))
    )

    allow(short_url_service_double).to receive(:short_url).and_return("reset_url")
  end

  describe "POST /create" do
    subject(:request) do
      post user_password_url, params: params

      response
    end

    context "with valid parameters" do
      let(:params) { {user: {email: user.email, phone_number: user.phone_number}} }

      it "sends a password reset SMS to existing user" do
        request
        expect(twilio_service_double).to have_received(:send_sms).once.with(
          {From: org.twilio_phone_number, Body: a_string_matching("reset_url"), To: user.phone_number}
        )
      end

      it "sends a password reset email to existing user" do
        expect { request }.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(ActionMailer::Base.deliveries.last.to).to include(user.email)
      end

      it { is_expected.to redirect_to(user_session_url) }

      it "shows the correct flash message" do
        request
        expect(flash[:notice]).to(
          eq("If the account exists you will receive an email or SMS with instructions on how to reset your password in a few minutes.")
        )
      end

      describe "(email only)" do
        let(:params) { {user: {email: user.email, phone_number: ""}} }

        it "sends a password reset email to existing user" do
          expect { request }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(ActionMailer::Base.deliveries.last.to).to include(user.email)
        end

        it "does not send sms with reset password" do
          request
          expect(twilio_service_double).not_to have_received(:send_sms)
        end
      end

      describe "(phone_number only)" do
        let(:params) { {user: {email: "", phone_number: user.phone_number}} }

        it "sends a password reset SMS to existing user" do
          request
          expect(twilio_service_double).to have_received(:send_sms).once.with(
            {From: org.twilio_phone_number, Body: a_string_matching("reset_url"), To: user.phone_number}
          )
        end

        it "does not send email with reset password" do
          expect { request }.not_to change { ActionMailer::Base.deliveries.count }
        end
      end
    end

    context "with invalid parameters" do
      let(:params) { {user: {email: "", phone_number: ""}} }

      it "sets errors correctly" do
        request
        expect(request.parsed_body.to_html).to include("Please enter at least one field.")
      end
    end

    context "with wrong parameters (non-existent user)" do
      let(:params) { {user: {phone_number: "13333333333"}} }

      it "does not reveal if user exists (security)" do
        request
        expect(flash[:notice]).to(
          eq("If the account exists you will receive an email or SMS with instructions on how to reset your password in a few minutes.")
        )
      end
    end

    context "with invalid phone number format" do
      let(:params) { {user: {email: "", phone_number: "1234"}} }

      it "shows phone number validation error" do
        request
        expect(request.parsed_body.to_html).to include("phone_number")
      end
    end

    context "with non-numeric phone number" do
      let(:params) { {user: {email: "", phone_number: "abc"}} }

      it "shows phone number validation error" do
        request
        expect(request.parsed_body.to_html).to include("phone_number")
      end
    end

    context "when twilio is disabled" do
      let(:params) { {user: {email: user.email, phone_number: user.phone_number}} }

      before do
        org.update(twilio_enabled: false)
      end

      it "does not send an sms, only an email" do
        expect { request }.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(flash[:notice]).to(
          eq("If the account exists you will receive an email or SMS with instructions on how to reset your password in a few minutes.")
        )
      end
    end

    context "when email sending times out with Net::ReadTimeout" do
      let(:params) { {user: {email: user.email, phone_number: user.phone_number}} }

      before do
        allow(user).to receive(:send_reset_password_instructions).and_raise(Net::ReadTimeout)
        allow(User).to receive(:find_by).and_return(user)
      end

      it "handles the timeout gracefully and still shows success message" do
        expect(Rails.logger).to receive(:error).with(/Password reset email failed to send/)
        request
        expect(flash[:notice]).to(
          eq("If the account exists you will receive an email or SMS with instructions on how to reset your password in a few minutes.")
        )
      end

      it "does not crash the request" do
        expect { request }.not_to raise_error
        expect(response).to redirect_to(user_session_url)
      end

      it "notifies Bugsnag of the error" do
        expect(Bugsnag).to receive(:notify).with(instance_of(Net::ReadTimeout))
        request
      end

      it "generates a fallback token for SMS to use" do
        expect(user).to receive(:generate_password_reset_token).and_call_original
        request
      end

      it "still sends SMS with the fallback token" do
        request
        expect(twilio_service_double).to have_received(:send_sms).once
      end
    end

    context "when email sending times out with Net::OpenTimeout" do
      let(:params) { {user: {email: user.email, phone_number: ""}} }

      before do
        allow(user).to receive(:send_reset_password_instructions).and_raise(Net::OpenTimeout)
        allow(User).to receive(:find_by).and_return(user)
      end

      it "handles the timeout gracefully and still shows success message" do
        expect(Rails.logger).to receive(:error).with(/Password reset email failed to send/)
        request
        expect(flash[:notice]).to(
          eq("If the account exists you will receive an email or SMS with instructions on how to reset your password in a few minutes.")
        )
      end

      it "does not crash the request" do
        expect { request }.not_to raise_error
        expect(response).to redirect_to(user_session_url)
      end

      it "notifies Bugsnag of the error" do
        expect(Bugsnag).to receive(:notify).with(instance_of(Net::OpenTimeout))
        request
      end
    end

    context "when SMS sending fails" do
      let(:params) { {user: {email: "", phone_number: user.phone_number}} }

      before do
        allow(twilio_service_double).to receive(:send_sms).and_raise(Twilio::REST::TwilioError.new("Service unavailable"))
      end

      it "raises the error (no rescue in controller)" do
        expect { request }.to raise_error(Twilio::REST::TwilioError)
      end
    end
  end

  describe "PUT /update" do
    let(:token) do
      raw_token, enc_token = Devise.token_generator.generate(User, :reset_password_token)
      user.update!(reset_password_token: enc_token, reset_password_sent_at: Time.current)
      raw_token
    end

    let(:params) do
      {
        user: {
          reset_password_token: token,
          password: "newpassword123!",
          password_confirmation: "newpassword123!"
        }
      }
    end

    subject(:request) { put user_password_path, params: params }

    context "with valid token and password" do
      it "successfully resets the password" do
        request
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:notice]).to eq("Your password has been changed successfully.")
      end

      it "allows user to sign in with new password" do
        request
        user.reload
        expect(user.valid_password?("newpassword123!")).to be true
      end
    end

    context "with password mismatch" do
      let(:params) do
        {
          user: {
            reset_password_token: token,
            password: "newpassword123!",
            password_confirmation: "differentpassword123!"
          }
        }
      end

      it "does not reset the password" do
        old_password_digest = user.encrypted_password
        request
        user.reload
        expect(user.encrypted_password).to eq(old_password_digest)
      end
    end

    context "with password too short" do
      let(:params) do
        {
          user: {
            reset_password_token: token,
            password: "abc",
            password_confirmation: "abc"
          }
        }
      end

      it "does not reset the password" do
        old_password_digest = user.encrypted_password
        request
        user.reload
        expect(user.encrypted_password).to eq(old_password_digest)
      end
    end
  end
end

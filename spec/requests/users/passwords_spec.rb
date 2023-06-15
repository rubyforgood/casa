require "rails_helper"

RSpec.describe "Users::PasswordsController", type: :request do
  let!(:org) { create(:casa_org) }
  let!(:user) { create(:user, phone_number: "+12222222222", casa_org: org) }

  let!(:twillio_service_double) { instance_double(TwilioService) }
  let!(:short_url_service_double) { instance_double(ShortUrlService) }

  before do
    allow(TwilioService).to(
      receive(:new).with(
        org
      ).and_return(twillio_service_double)
    )

    allow(twillio_service_double).to receive(:send_sms)

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
        expect(twillio_service_double).to have_received(:send_sms).once.with(
          {From: org.twilio_phone_number, Body: a_string_matching("reset_url"), To: user.phone_number}
        )
      end

      it "sends a password reset email to existing user" do
        expect_any_instance_of(User).to receive(:send_reset_password_instructions).once
        request
      end

      it { is_expected.to redirect_to(user_session_url) }

      it "shows the correct flash message" do
        request
        expect(flash[:notice]).to(
          eq("You will receive an email or SMS with instructions on how to reset your password in a few minutes.")
        )
      end

      describe "(email only)" do
        let(:params) { {user: {email: user.email, phone_number: ""}} }

        it "sends a password reset email to existing user" do
          expect_any_instance_of(User).to receive(:send_reset_password_instructions).once
          request
        end

        it "does not send sms with reset password" do
          request
          expect(twillio_service_double).not_to have_received(:send_sms)
        end
      end

      describe "(phone_number only)" do
        let(:params) { {user: {email: "", phone_number: user.phone_number}} }

        it "sends a password reset SMS to existing user" do
          request
          expect(twillio_service_double).to have_received(:send_sms).once.with(
            {From: org.twilio_phone_number, Body: a_string_matching("reset_url"), To: user.phone_number}
          )
        end

        it "does not send email with reset password" do
          expect_any_instance_of(User).not_to receive(:send_reset_password_instructions)
          request
        end
      end
    end

    context "with invalid parameters" do
      let(:params) { {user: {email: "", phone_number: ""}} }

      it "sets errors correctly" do
        request
        expect(request.parsed_body).to include("Please enter at least one field.")
      end
    end

    context "with wrong parameters" do
      let(:params) { {user: {phone_number: "13333333333"}} }

      it "sets errors correctly" do
        request
        expect(request.parsed_body).to include("User does not exist.")
      end
    end

    context "when twilio is disabled" do
      let(:params) { {user: {email: user.email, phone_number: user.phone_number}} }

      before do
        org.update(twilio_enabled: false)
      end

      it "does not send an sms, only an email" do
        expect_any_instance_of(User).to receive(:send_reset_password_instructions).once
        request
        expect(flash[:notice]).to(
          eq("You will receive an email or SMS with instructions on how to reset your password in a few minutes.")
        )
      end
    end
  end
end

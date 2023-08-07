require "rails_helper"
require "support/stubbed_requests/webmock_helper"

RSpec.describe NoContactMadeSmsReminderService do
  include SmsBodyHelper

  describe "court report due sms reminder service" do
    let(:org) { create(:casa_org, twilio_enabled: true) }
    let!(:volunteer) { create(:volunteer, receive_sms_notifications: true, phone_number: "+12222222222", casa_org: org) }
    let!(:contact_type) { "test" }

    before :each do
      WebMockHelper.short_io_stub_localhost
      WebMockHelper.twilio_no_contact_made_stub
      WebMock.disable_net_connect!
    end

    context "when sending sms reminder" do
      it "should send a SMS with a short url successfully" do
        response = NoContactMadeSmsReminderService.no_contact_made_reminder(volunteer, contact_type)

        expect(response.error_code).to match nil
        expect(response.status).to match "sent"
        expect(response.body).to match no_contact_made_msg(contact_type, "https://42ni.short.gy/jzTwdF")
      end
    end

    context "when volunteer is not opted into sms notifications" do
      let(:volunteer) { create(:volunteer, receive_sms_notifications: false) }

      it "should not send a SMS" do
        response = NoContactMadeSmsReminderService.no_contact_made_reminder(volunteer, contact_type)
        expect(response).to be_nil
      end
    end

    context "when volunteer does not have a valid phone number" do
      let(:volunteer) { create(:volunteer, phone_number: nil) }

      it "should not send a SMS" do
        response = NoContactMadeSmsReminderService.no_contact_made_reminder(volunteer, contact_type)
        expect(response).to be_nil
      end
    end

    context "when volunteer's casa_org does not have twilio enabled" do
      let(:casa_org) { create(:casa_org, twilio_enabled: false) }
      let(:volunteer) { create(:volunteer, casa_org: casa_org) }

      it "should not send a SMS" do
        response = NoContactMadeSmsReminderService.no_contact_made_reminder(volunteer, contact_type)
        expect(response).to be_nil
      end
    end
  end
end

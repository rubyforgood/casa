require "rails_helper"
require "support/stubbed_requests/webmock_helper"

RSpec.describe SmsReminderService do
  describe "court report due sms reminder service" do
    let(:org) { create(:casa_org, twilio_enabled: true) }
    let!(:volunteer) { create(:volunteer, casa_org: org, receive_sms_notifications: true, phone_number: "+12222222222") }
    let!(:message) { "It's been two weeks since you've tried reaching 'test'. Try again! https://42ni.short.gy/jzTwdF" }

    before :each do
      WebMockHelper.short_io_stub_localhost
      WebMockHelper.twilio_no_contact_made_stub
      WebMock.disable_net_connect!
    end

    context "when sending sms reminder" do
      it "should send a SMS with a short url successfully" do
        response = SmsReminderService.send_reminder(volunteer, message)

        expect(response.error_code).to match nil
        expect(response.status).to match "sent"
        expect(response.body).to match "It's been two weeks since you've tried reaching 'test'. Try again! https://42ni.short.gy/jzTwdF"
      end
    end

    context "when volunteer is not opted into sms notifications" do
      let(:volunteer) { create(:volunteer, receive_sms_notifications: false) }

      it "should not send a SMS" do
        response = SmsReminderService.send_reminder(volunteer, message)
        expect(response).to be_nil
      end
    end

    context "when volunteer does not have a valid phone number" do
      let(:volunteer) { create(:volunteer, phone_number: nil) }

      it "should not send a SMS" do
        response = SmsReminderService.send_reminder(volunteer, message)
        expect(response).to be_nil
      end
    end

    context "when a volunteer's casa_org does not have twilio enabled" do
      let(:casa_org_twilio_disabled) { create(:casa_org, twilio_enabled: false) }
      let(:volunteer_twilio_disabled) { create(:volunteer, casa_org: casa_org_twilio_disabled) }

      it "should not send a SMS" do
        response = SmsReminderService.send_reminder(volunteer_twilio_disabled, message)
        expect(response).to be_nil
      end
    end
  end
end

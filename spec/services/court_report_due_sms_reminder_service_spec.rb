require "rails_helper"
require "support/stubbed_requests/webmock_helper"

RSpec.describe CourtReportDueSmsReminderService do
  include SmsBodyHelper

  describe "court report due sms reminder service" do
    let!(:volunteer) { create(:volunteer, receive_sms_notifications: true, phone_number: "+12223334444") }
    let!(:report_due_date) { Date.current + 7.days }

    before :each do
      WebMockHelper.short_io_court_report_due_date_stub
      WebMockHelper.twilio_court_report_due_date_stub
      WebMock.disable_net_connect!
    end

    context "when sending sms reminder" do
      it "should send a SMS with a short url successfully" do
        response = CourtReportDueSmsReminderService.court_report_reminder(volunteer, report_due_date)

        expect(response.error_code).to match nil
        expect(response.status).to match "sent"
        expect(response.body).to match court_report_due_msg(report_due_date, "https://42ni.short.gy/jzTwdF")
      end
    end

    context "when volunteer is not opted into sms notifications" do
      let(:volunteer) { create(:volunteer, receive_sms_notifications: false) }

      it "should not send a SMS" do
        response = CourtReportDueSmsReminderService.court_report_reminder(volunteer, report_due_date)
        expect(response).to be_nil
      end
    end

    context "when volunteer does not have a valid phone number" do
      let(:volunteer) { create(:volunteer, phone_number: nil) }

      it "should not send a SMS" do
        response = CourtReportDueSmsReminderService.court_report_reminder(volunteer, report_due_date)
        expect(response).to be_nil
      end
    end

    context "when volunteer's casa_org does not have twilio enabled" do
      let(:org) { create(:casa_org, twilio_enabled: false) }
      let(:volunteer_2) { create(:volunteer, casa_org: org) }

      it "should not send a SMS" do
        response = CourtReportDueSmsReminderService.court_report_reminder(volunteer_2, report_due_date)
        expect(response).to be_nil
      end
    end
  end
end

require "rails_helper"
require "support/stubbed_requests/webmock_helper"

RSpec.describe CourtReportDueSmsReminderService do
  include SmsBodyHelper

  subject { described_class.court_report_reminder(volunteer, report_due_date) }

  let(:org) { create(:casa_org, twilio_enabled: true) }
  let!(:volunteer) { create(:volunteer, casa_org: org, receive_sms_notifications: true, phone_number: "+12223334444") }
  let!(:report_due_date) { Date.current + 7.days }

  before do
    WebMockHelper.short_io_court_report_due_date_stub
    WebMockHelper.twilio_court_report_due_date_stub
  end

  context "when sending sms reminder" do
    it "sends a SMS with a short url successfully" do
      expect(subject.error_code).to match nil
      expect(subject.status).to match "sent"
      expect(subject.body).to match court_report_due_msg(report_due_date, "https://42ni.short.gy/jzTwdF")
    end
  end

  context "when volunteer is not opted into sms notifications" do
    let(:volunteer) { create(:volunteer, receive_sms_notifications: false) }

    it "does not send a SMS" do
      expect(subject).to be_nil
    end
  end

  context "when volunteer does not have a valid phone number" do
    let(:volunteer) { create(:volunteer, phone_number: nil) }

    it "does not send a SMS" do
      expect(subject).to be_nil
    end
  end

  context "when volunteer's casa_org does not have twilio enabled" do
    let(:org) { create(:casa_org, twilio_enabled: false) }

    it "does not send a SMS and returns nil" do
      expect(subject).to be_nil
    end
  end
end

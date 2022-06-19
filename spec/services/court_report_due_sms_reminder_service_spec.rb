require "rails_helper"
require "support/stubbed_requests/webmock_helper"

RSpec.describe TwilioService do
  describe "court report due sms reminder service" do
    let!(:volunteer) { create(:volunteer) }
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
        expect(response.body).to match "Your court report is due on 2022-06-26. Generate a court report to complete & submit here: https://42ni.short.gy/jzTwdF"
      end
    end
  end
end

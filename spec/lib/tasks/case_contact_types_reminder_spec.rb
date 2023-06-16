require "rails_helper"
require_relative "../../../lib/tasks/case_contact_types_reminder"
require "support/stubbed_requests/webmock_helper"

RSpec.describe CaseContactTypesReminder do
  let!(:casa_org) do
    create(
      :casa_org,
      twilio_phone_number: "+15555555555",
      twilio_account_sid: "articuno34",
      twilio_api_key_sid: "Aladdin",
      twilio_api_key_secret: "open sesame"
    )
  end
  let!(:volunteer) do
    create(
      :volunteer,
      casa_org_id: casa_org.id,
      phone_number: "+12222222222",
      receive_sms_notifications: true
    )
  end
  let!(:contact_type) { create(:contact_type, name: "test") }
  let!(:case_contact) do
    create(
      :case_contact,
      creator: volunteer,
      contact_types: [contact_type],
      occurred_at: 4.months.ago
    )
  end

  before do
    WebMockHelper.twilio_success_stub
    WebMockHelper.twilio_success_stub_messages_60_days
    WebMockHelper.short_io_stub_localhost
    WebMock.disable_net_connect!
  end

  context "volunteer with uncontacted contact types, sms notifications on, and no reminder in last quarter" do
    it "should send sms reminder" do
      responses = CaseContactTypesReminder.new.send!
      expect(responses.count).to eq 1
      expect(responses[0][:messages][0].body).to include CaseContactTypesReminder::FIRST_MESSAGE.strip
      expect(responses[0][:messages][1].body).to include contact_type.name
      expect(responses[0][:messages][2].body).to match CaseContactTypesReminder::THIRD_MESSAGE + "https://42ni.short.gy/jzTwdF"
    end
  end

  context "volunteer with contacted contact types within last 60 days, sms notifications on, and no reminder in last quarter" do
    it "should send sms reminder" do
      CaseContact.update_all(occurred_at: 1.months.ago)
      responses = CaseContactTypesReminder.new.send!
      expect(responses.count).to match 0
    end
  end

  context "volunteer with uncontacted contact types, sms notifications off, and no reminder in last quarter" do
    it "should not send sms reminder" do
      Volunteer.update_all(receive_sms_notifications: false)
      responses = CaseContactTypesReminder.new.send!
      expect(responses.count).to match 0
    end
  end

  context "volunteer with uncontacted contact types, sms notifications on, and reminder in last quarter" do
    it "should not send sms reminder" do
      create(:user_reminder_time, :case_contact_types)
      Volunteer.update_all(receive_sms_notifications: true)
      responses = CaseContactTypesReminder.new.send!
      expect(responses.count).to match 0
    end
  end

  context "volunteer with uncontacted contact types, sms notifications on, and reminder out of last quarter" do
    it "should send sms reminder" do
      UserReminderTime.destroy_all
      Volunteer.all do |v|
        create(:user_case_contact_types_reminder, user_id: v.id, reminder_sent: 4.months.ago)
      end
      responses = CaseContactTypesReminder.new.send!
      expect(responses.count).to match 1
      expect(responses[0][:messages][0].body).to eq CaseContactTypesReminder::FIRST_MESSAGE.strip
      expect(responses[0][:messages][1].body).to include contact_type.name
      expect(responses[0][:messages][2].body).to match CaseContactTypesReminder::THIRD_MESSAGE + "https://42ni.short.gy/jzTwdF"
    end
  end
end

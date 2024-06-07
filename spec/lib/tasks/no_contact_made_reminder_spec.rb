require "rails_helper"
require_relative "../../../lib/tasks/no_contact_made_reminder"
require "support/stubbed_requests/webmock_helper"

RSpec.describe NoContactMadeReminder do
  let!(:casa_org) do
    create(
      :casa_org,
      twilio_enabled: true,
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
      occurred_at: 1.week.ago,
      contact_made: false
    )
  end
  let!(:expected_sms) { "It's been two weeks since you've tried reaching 'test'. Try again! https://42ni.short.gy/jzTwdF" }

  before do
    WebMockHelper.twilio_success_stub
    WebMockHelper.twilio_no_contact_made_stub
    WebMockHelper.short_io_stub_localhost
  end

  context "volunteer with no contact made in past 2 weeks in case contact" do
    it "should send sms reminder" do
      responses = NoContactMadeReminder.new.send!
      expect(responses.count).to eq 1
      expect(responses[0][:volunteer]).to eq(volunteer)
      expect(responses[0][:message].body).to eq expected_sms
    end
  end

  context "volunteer with contact made after not making contact" do
    let(:case_contact) do
      create(
        :case_contact,
        creator: volunteer,
        contact_types: [contact_type],
        occurred_at: 2.days.ago,
        contact_made: true
      )
    end

    it "should send not sms reminder" do
      responses = NoContactMadeReminder.new.send!
      expect(responses.count).to eq 0
    end
  end

  context "volunteer with contact made after not making contact but volunteer is no longer assigned to the case" do
    let(:case_contact) do
      create(
        :case_contact,
        creator: create(:volunteer), # different volunteer assigned
        contact_types: [contact_type],
        occurred_at: 1.week.ago,
        contact_made: false
      )
    end

    it "should send not sms reminder" do
      responses = NoContactMadeReminder.new.send!
      expect(responses.count).to eq 0
    end
  end

  context "volunteer with no case contacts" do
    it "should send not sms reminder" do
      CaseContact.destroy_all
      responses = NoContactMadeReminder.new.send!
      expect(responses.count).to eq 0
    end
  end

  context "volunteer with quarterly case contact type reminder sent on same day" do
    let(:quarterly_reminder) { create(:user_reminder_time, :quarterly_reminder) }

    it "should send not sms reminder" do
      CaseContact.destroy_all
      responses = NoContactMadeReminder.new.send!
      expect(responses.count).to eq 0
    end
  end

  context "volunteer with no contact made reminder sent within last 30 days" do
    let(:no_contact_made_reminder) { create(:user_reminder_time, no_contact_made: 1.weeks.ago) }

    it "should send not sms reminder" do
      CaseContact.destroy_all
      responses = NoContactMadeReminder.new.send!
      expect(responses.count).to eq 0
    end
  end

  context "volunteer with sms notification off" do
    let(:volunteer) {
      create(
        :volunteer,
        casa_org_id: casa_org.id,
        phone_number: "+12222222222",
        receive_sms_notifications: false
      )
    }

    it "should send not sms reminder" do
      responses = NoContactMadeReminder.new.send!
      expect(responses.count).to eq 0
    end
  end
end

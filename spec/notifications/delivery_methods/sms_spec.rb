require "rails_helper"
require "support/stubbed_requests/webmock_helper"

RSpec.describe DeliveryMethods::Sms do
  let(:casa_org) { create(:casa_org, twilio_enabled: true) }
  let(:recipient) { create(:volunteer, casa_org: casa_org, phone_number: "+12222222222") }
  let(:case_contact) { create(:case_contact) }
  let(:followup) { create(:followup, creator: sender, case_contact: case_contact) }
  let(:event) { create(:followup_notifier, params: {followup: followup, created_by: sender}, record: followup) }
  let(:notification) { create(:notification, event: event, recipient: recipient) }
  let(:case_contact_edit_url) do
    "#{Rails.application.credentials[:BASE_URL]}/case_contacts/#{case_contact.id}/edit?notification_id=#{followup.id}"
  end

  before do
    allow(event).to receive(:delivery_methods).and_return({sms: Noticed::Deliverable::DeliverBy.new(:sms, {})})
    WebMockHelper.short_io_stub_sms
    WebMockHelper.twilio_activation_success_stub
  end

  def deliver_notification
    described_class.new.perform(:sms, notification)
  end

  context "when the sender is a casa admin" do
    let(:sender) { create(:casa_admin, casa_org: casa_org) }

    it "sends an sms with the flagged case contact message and shortened url" do
      deliver_notification

      expect(a_request(:post, "https://api.twilio.com/2010-04-01/Accounts/articuno34/Messages.json")
        .with(body: {
          From: casa_org.twilio_phone_number,
          Body: "#{sender.display_name} has flagged a Case Contact that needs follow up. Click to see more: https://42ni.short.gy/jzTwdF",
          To: recipient.phone_number
        })).to have_been_made.once
    end

    it "shortens the case contact edit url" do
      deliver_notification

      expect(a_request(:post, "https://api.short.io/links")
        .with(body: {originalURL: case_contact_edit_url, domain: "42ni.short.gy"}.to_json))
        .to have_been_made.once
    end
  end

  context "when the sender is a supervisor" do
    let(:sender) { create(:supervisor, casa_org: casa_org) }

    it "sends an sms" do
      deliver_notification

      expect(a_request(:post, "https://api.twilio.com/2010-04-01/Accounts/articuno34/Messages.json"))
        .to have_been_made.once
    end
  end

  context "when the sender is a volunteer" do
    let(:sender) { create(:volunteer, casa_org: casa_org) }

    it "does not send an sms" do
      deliver_notification

      expect(a_request(:post, "https://api.twilio.com/2010-04-01/Accounts/articuno34/Messages.json"))
        .not_to have_been_made
      expect(a_request(:post, "https://api.short.io/links")).not_to have_been_made
    end
  end
end

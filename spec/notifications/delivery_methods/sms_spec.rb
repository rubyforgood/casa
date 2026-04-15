require "rails_helper"

RSpec.describe DeliveryMethods::Sms do
  let(:organization) { create(:casa_org) }
  let(:notification) { create(:notification) }
  let(:case_contact) { create(:case_contact) }

  let(:params) do
    {followup: {creator_id: sender.id, case_contact_id: case_contact.id}}
  end

  let(:sms_delivery) do
    described_class.new.tap do |delivery|
      allow(delivery).to receive(:params).and_return(params)
      allow(delivery).to receive(:record).and_return(notification)
      allow(delivery).to receive(:recipient).and_return(recipient)
    end
  end

  let(:recipient) { create(:volunteer, casa_org: organization, phone_number: "+15555555555") }

  describe "#deliver" do
    let(:short_url_service) { instance_double(ShortUrlService, create_short_url: nil, short_url: "https://short.url/abc") }
    let(:twilio_service) { instance_double(TwilioService, send_sms: nil) }

    before do
      allow(ShortUrlService).to receive(:new).and_return(short_url_service)
      allow(TwilioService).to receive(:new).and_return(twilio_service)
    end

    context "when sender is a casa admin" do
      let(:sender) { create(:casa_admin, casa_org: organization) }

      it "sends an SMS via Twilio" do
        sms_delivery.deliver

        expect(twilio_service).to have_received(:send_sms)
      end

      it "creates a short URL for the case contact" do
        sms_delivery.deliver

        expect(short_url_service).to have_received(:create_short_url)
      end
    end

    context "when sender is a supervisor" do
      let(:sender) { create(:supervisor, casa_org: organization) }

      it "sends an SMS via Twilio" do
        sms_delivery.deliver

        expect(twilio_service).to have_received(:send_sms)
      end
    end

    context "when sender is a volunteer" do
      let(:sender) { create(:volunteer, casa_org: organization) }

      it "does not send an SMS" do
        sms_delivery.deliver

        expect(twilio_service).not_to have_received(:send_sms)
      end
    end
  end

  describe "#case_contact_url" do
    let(:sender) { create(:casa_admin, casa_org: organization) }

    it "includes the case contact id and notification id" do
      url = sms_delivery.case_contact_url

      expect(url).to include("/case_contacts/#{case_contact.id}/edit")
      expect(url).to include("notification_id=#{notification.id}")
    end
  end
end

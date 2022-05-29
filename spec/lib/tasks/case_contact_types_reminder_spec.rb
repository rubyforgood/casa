require "rails_helper"
require_relative "../../../lib/tasks/case_contact_types_reminder"
require "support/webmock_helper"

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

    before do
        stubbed_requests
        WebMock.disable_net_connect!
    end
    
    context "volunteer with uncontacted contact types, sms notifications on, and no reminder in last quarter" do
        it "should send sms reminder" do
            responses = CaseContactTypesReminder.new.send!
            expect(responses.count).to match 1
            expect(responses[0][:messages][0].body).to match CaseContactTypesReminder::FIRST_MESSAGE
            expect(responses[0][:messages][1].body).to match contact_type.name
            expect(responses[0][:messages][2].body).to match CaseContactTypesReminder::THIRD_MESSAGE
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
            create(:user_case_contact_types_reminder, user_id: volunteer.id)
            Volunteer.update_all(receive_sms_notifications: true)
            responses = CaseContactTypesReminder.new.send!
            expect(responses.count).to match 0
        end
    end

    context "volunteer with uncontacted contact types, sms notifications on, and reminder out of last quarter" do     
        it "should send sms reminder" do
            UserCaseContactTypesReminder.destroy_all
            Volunteer.all do |v|
                create(:user_case_contact_types_reminder, user_id: v.id, reminder_sent: 4.months.ago)
            end
            responses = CaseContactTypesReminder.new.send!
            expect(responses.count).to match 1
            expect(responses[0][:messages][0].body).to match CaseContactTypesReminder::FIRST_MESSAGE
            expect(responses[0][:messages][1].body).to match contact_type.name
            expect(responses[0][:messages][2].body).to match CaseContactTypesReminder::THIRD_MESSAGE
        end
    end

    context "volunteer with uncontacted contact types, sms notifications on, no reminder in last quarter, no phone number" do
        it "should not send sms reminder" do
            UserCaseContactTypesReminder.destroy_all
            Volunteer.update_all(phone_number: nil)
            responses = CaseContactTypesReminder.new.send!
            expect(responses.count).to match 0
        end
    end
end
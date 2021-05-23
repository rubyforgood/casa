require "rails_helper"

RSpec.describe VolunteerMailer, type: :mailer do
  let(:volunteer) { create(:volunteer) }

  describe ".deactivation" do
    let(:mail) { VolunteerMailer.deactivation(volunteer) }

    it "sends an email saying the account has been deactivated" do
      expect(mail.body.encoded).to match("Hello #{volunteer.display_name}")
      expect(mail.body.encoded).to match("has been deactivated")
    end
  end

  describe ".account_setup" do
    let(:mail) { VolunteerMailer.account_setup(volunteer) }

    it "generates a password reset token and sends email" do
      expect(volunteer.reset_password_token).to be_nil
      expect(volunteer.reset_password_sent_at).to be_nil
      expect(mail.body.encoded.squish).to match("Set Your Password")
      expect(volunteer.reset_password_token).to_not be_nil
      expect(volunteer.reset_password_sent_at).to_not be_nil
    end
  end

  describe ".court_report_reminder" do
    let(:report_due_date) { Date.current + 7.days }
    let(:mail) { VolunteerMailer.court_report_reminder(volunteer, report_due_date) }

    it "sends email reminder" do
      expect(mail.body.encoded).to match("next court report is due on #{report_due_date}")
    end
  end

  describe ".case_contacts_reminder" do
    let(:mail) { VolunteerMailer.case_contacts_reminder(volunteer) }

    it "sends an email reminding volunteer" do
      expect(mail.body.encoded).to match("Hello #{volunteer.display_name}")
      expect(mail.body.encoded).to match("as a reminder")
    end
  end
end

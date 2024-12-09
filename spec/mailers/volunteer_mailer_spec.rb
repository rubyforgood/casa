require "rails_helper"

RSpec.describe VolunteerMailer, type: :mailer do
  let(:volunteer) { create(:volunteer) }
  let(:volunteer_with_supervisor) { create(:volunteer, :with_assigned_supervisor) }

  describe ".account_setup" do
    let(:mail) { VolunteerMailer.account_setup(volunteer) }

    it "generates a password reset token and sends email" do
      expect(volunteer.reset_password_token).to be_nil
      expect(volunteer.reset_password_sent_at).to be_nil
      expect(mail.body.encoded.squish).to match("Set Your Password")
      expect(volunteer.reset_password_token).not_to be_nil
      expect(volunteer.reset_password_sent_at).not_to be_nil
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
    it "sends an email reminding volunteer" do
      mail = VolunteerMailer.case_contacts_reminder(volunteer, [])
      expect(mail.body.encoded).to match("Hello #{volunteer.display_name}")
      expect(mail.body.encoded).to match("as a reminder")
      expect(mail.body.encoded).to include(case_contacts_url.to_s)
      expect(mail.cc).to be_empty
    end

    it "sends and cc's recipients" do
      cc_recipients = %w[supervisor@example.com admin@example.com]
      mail = VolunteerMailer.case_contacts_reminder(volunteer, cc_recipients)
      expect(mail.cc).to match_array(cc_recipients)
    end
  end

  describe ".invitation_instructions for a volunteer" do
    let(:mail) { volunteer.invite! }
    let(:expiration_date) { I18n.l(volunteer.invitation_due_at, format: :full, default: nil) }

    it "informs the correct expiration date" do
      email_body = mail.html_part.body.to_s.squish
      expect(email_body).to include("This invitation will expire on #{expiration_date} (one year).")
    end
  end
end

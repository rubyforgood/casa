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

  describe ".reimbursement_complete_email" do
    let(:case_contact) { create(:case_contact, :wants_reimbursement, creator: volunteer) }
    let(:mail) { VolunteerMailer.reimbursement_complete_email(volunteer, case_contact) }

    it "sends an email confirming the reimbursement was processed" do
      expect(mail.to).to eq([volunteer.email])
      expect(mail.subject).to eq("Your reimbursement request has been processed")
      expect(mail.body.encoded).to match("#{case_contact.miles_driven}mi")
      expect(mail.body.encoded).to match(case_contact.occurred_at_display)
    end

    context "when the casa org has a mileage rate" do
      let!(:mileage_rate) { create(:mileage_rate, casa_org: case_contact.casa_case.casa_org, amount: 6.50, effective_date: 3.days.ago) }

      it "includes the reimbursement amount" do
        # Bare "$" is a regex end-anchor via String#match, not a literal dollar sign.
        expect(mail.body.encoded).to match(/\$[\d,]+\.\d{2}/)
      end
    end

    context "when the casa org has no mileage rate" do
      it "omits the reimbursement amount rather than rendering a blank or nil value" do
        expect(mail.body.encoded).not_to match(/\$[\d,]+\.\d{2}/)
      end
    end

    describe "the currency pattern itself" do
      # An unescaped "." would still match a real decimal point, so neither
      # test above would catch it regressing; guard the escape directly.
      it "does not match if the decimal point is some other character" do
        expect("$40X50").not_to match(/\$[\d,]+\.\d{2}/)
      end
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

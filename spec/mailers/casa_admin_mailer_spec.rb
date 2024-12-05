require "rails_helper"

RSpec.describe CasaAdminMailer, type: :mailer do
  let(:casa_admin) { create(:casa_admin) }

  describe ".account_setup for an admin" do
    let(:mail) { CasaAdminMailer.account_setup(casa_admin) }

    it "sends an email saying the account has been created" do
      expect(mail.body.encoded).to match("A #{casa_admin.casa_org.display_name}’s County Admin account")
      expect(mail.body.encoded).to match("has been created for you")
    end

    it "generates a password reset token and sends email" do
      expect(casa_admin.reset_password_token).to be_nil
      expect(casa_admin.reset_password_sent_at).to be_nil
      expect(mail.body.encoded.squish).to match("Set Your Password")
      expect(casa_admin.reset_password_token).not_to be_nil
      expect(casa_admin.reset_password_sent_at).not_to be_nil
    end
  end

  describe ".invitation_instructions for an all casa admin" do
    let!(:all_casa_admin) { create(:all_casa_admin) }
    let!(:mail) { all_casa_admin.invite! }

    it "informs the correct expiration date" do
      expiration_date = I18n.l(all_casa_admin.invitation_due_at, format: :full, default: nil)

      email_body = mail.html_part.body.to_s.squish
      expect(email_body).to include("This invitation will expire on #{expiration_date} (one week).")
    end
  end

  describe ".invitation_instructions for a casa admin" do
    let!(:casa_admin) { create(:casa_admin) }
    let!(:mail) { casa_admin.invite! }

    it "informs the correct expiration date" do
      expiration_date = I18n.l(casa_admin.invitation_due_at, format: :full, default: nil)

      email_body = mail.html_part.body.to_s.squish
      expect(email_body).to include("This invitation will expire on #{expiration_date} (two weeks).")
    end
  end
end

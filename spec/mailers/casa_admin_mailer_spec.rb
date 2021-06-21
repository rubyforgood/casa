require "rails_helper"

RSpec.describe CasaAdminMailer, type: :mailer do
  let(:casa_admin) { create(:casa_admin) }

  describe ".account_setup" do
    let(:mail) { CasaAdminMailer.account_setup(casa_admin) }

    it "sends an email saying the account has been created" do
      expect(mail.body.encoded).to match("A #{casa_admin.casa_org.display_name}’s County Admin account")
      expect(mail.body.encoded).to match("has been created for you")
    end

    it "generates a password reset token and sends email" do
      expect(casa_admin.reset_password_token).to be_nil
      expect(casa_admin.reset_password_sent_at).to be_nil
      expect(mail.body.encoded.squish).to match("Set Your Password")
      expect(casa_admin.reset_password_token).to_not be_nil
      expect(casa_admin.reset_password_sent_at).to_not be_nil
    end
  end
end

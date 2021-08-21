require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "password_changed_reminder" do
    subject(:mail) { described_class.password_changed_reminder(user) }

    let(:user) { create(:user) }

    it "renders the headers", :aggregate_failures do
      expect(mail.subject).to eq("CASA Password Changed")
      expect(mail.to).to eq([user.email])
    end

    it "renders the body", :aggregate_failures do
      expect(mail.body.encoded).to match("Hello #{user.display_name}")
      expect(mail.body.encoded).to match("Your CASA password has been changed.")
    end
  end
end

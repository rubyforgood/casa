require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "password_changed_reminder" do
    subject(:mail) { described_class.password_changed_reminder(user) }

    let(:user) { create(:user) }

    it "renders the headers", :aggregate_failures do
      expect(mail.subject).to eq("CASA password changed")
      expect(mail.to).to eq([user.email])
    end

    it "renders the body", :aggregate_failures do
      expect(mail.body.encoded).to match("Hello #{user.display_name}")
      expect(mail.body.encoded).to match("Your CASA password has been changed.")
    end
  end

  describe "followup_notification" do
    subject(:mail) { described_class.followup_notification(user, followup) }

    let(:user) { create(:volunteer) }
    let(:followup) { create(:followup, :with_note, note: "Please add the signature") }

    it "renders the headers", :aggregate_failures do
      expect(mail.subject).to eq("A case contact needs follow-up")
      expect(mail.to).to eq([user.email])
    end

    it "renders the body", :aggregate_failures do
      expect(mail.body.encoded).to match("Hello #{user.display_name}")
      expect(mail.body.encoded).to match("needs follow-up")
      expect(mail.body.encoded).to match("Please add the signature")
    end
  end

  describe "followup_resolved" do
    subject(:mail) { described_class.followup_resolved(user, followup) }

    let(:user) { create(:volunteer) }
    let(:followup) { create(:followup, :without_note) }

    it "renders the headers", :aggregate_failures do
      expect(mail.subject).to eq("A case contact follow-up was resolved")
      expect(mail.to).to eq([user.email])
    end

    it "renders the body", :aggregate_failures do
      expect(mail.body.encoded).to match("Hello #{user.display_name}")
      expect(mail.body.encoded).to match("has been resolved")
    end
  end
end

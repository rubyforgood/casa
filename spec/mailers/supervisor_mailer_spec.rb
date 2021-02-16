require "rails_helper"

RSpec.describe SupervisorMailer, :type => :mailer do
  describe ".weekly_digest" do
    let(:supervisor) { create(:supervisor) }
    let(:volunteer) { create(:volunteer, supervisor: supervisor) }
    let(:mail) { SupervisorMailer.weekly_digest(supervisor) }

    it "renders the body" do
      expect(mail.body.encoded).to match("Here's a summary of what happened with your volunteers this last week.")
    end
  end
end

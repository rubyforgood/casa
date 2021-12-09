require "rails_helper"
require File.join(Rails.root, "lib", "mailers", "previews", "volunteer_mailer_preview")

RSpec.describe VolunteerMailerPreview do
  let(:subject) { described_class.new }
  let!(:user) { create(:user) }

  describe "#account_setup" do
    let(:message) { subject.account_setup }

    it { expect(message.to).to eq [user.email] }
  end

  describe "#court_report_reminder" do
    let(:message) { subject.court_report_reminder }

    it { expect(message.to).to eq [user.email] }
  end

  describe "#case_contacts_reminder" do
    let(:message) { subject.case_contacts_reminder }

    it { expect(message.to).to eq [user.email] }
  end
end

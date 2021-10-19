require "rails_helper"
require File.join(Rails.root, "lib", "mailers", "previews", "supervisor_mailer_preview")

RSpec.describe SupervisorMailerPreview do
  let(:subject) { described_class.new }
  let!(:supervisor) { create(:supervisor) }

  describe "#account_setup" do
    let(:message) { subject.account_setup }

    it { expect(message.to).to eq [supervisor.email] }
  end

  describe "#weekly_digest" do
    let(:message) { subject.weekly_digest }

    it { expect(message.to).to eq [supervisor.email] }
  end
end

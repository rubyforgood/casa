require "rails_helper"
require File.join(Rails.root, "lib", "mailers", "previews", "supervisor_mailer_preview")

RSpec.describe SupervisorMailerPreview do
  let!(:supervisor) { create(:supervisor) }

  describe "#account_setup" do
    context "When no ID is passed" do
      let(:preview) { described_class.new }
      let(:email) { preview.account_setup }

      it { expect(email.to).to eq [supervisor.email] }
    end

    context "When passed ID is valid" do
      let(:preview) { described_class.new(id: supervisor.id) }
      let(:email) { preview.account_setup }

      it { expect(email.to).to eq [supervisor.email] }
    end

    context "When passed ID is invalid" do
      let(:preview) { described_class.new(id: -1) }
      let(:email) { preview.account_setup }

      it { expect(email.to).to eq ["missing_supervisor@example.com"] }
    end
  end

  describe "#weekly_digest" do
    context "When no ID is passed" do
      let(:preview) { described_class.new }
      let(:email) { preview.weekly_digest }

      xit { expect(email.to).to eq [supervisor.email] }
    end

    context "When passed ID is valid" do
      let(:preview) { described_class.new(id: supervisor.id) }
      let(:email) { preview.weekly_digest }

      xit { expect(email.to).to eq [supervisor.email] }
    end

    context "When passed ID is invalid" do
      let(:preview) { described_class.new(id: 3500) }
      let(:email) { preview.weekly_digest }

      xit { expect(email.to).to eq ["missing_supervisor@example.com"] }
    end
  end
end

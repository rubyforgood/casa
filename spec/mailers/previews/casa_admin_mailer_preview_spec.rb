require "rails_helper"
require File.join(Rails.root, "lib", "mailers", "previews", "casa_admin_mailer_preview")

RSpec.describe CasaAdminMailerPreview do
  let(:subject) { described_class.new }
  let!(:casa_admin) { create(:casa_admin) }

  describe "#account_setup" do
    let(:message) { subject.account_setup }

    it { expect(message.to).to eq [casa_admin.email] }
  end

  describe "#deactivation" do
    let(:message) { subject.deactivation }

    it { expect(message.to).to eq [casa_admin.email] }
  end
end

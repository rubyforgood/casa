require "rails_helper"
require File.join(Rails.root, "lib", "mailers", "previews", "casa_admin_mailer_preview")

RSpec.describe CasaAdminMailerPreview do
  let!(:casa_admin) { create(:casa_admin) }
  
  describe "#account_setup" do
    context "When no ID is passed" do
      let(:preview) { described_class.new }
      let(:email) { preview.account_setup }

      it { expect(email.to).to eq [casa_admin.email] }
    end
     
     context "When passed ID is valid" do
      let(:preview) {described_class.new(id: casa_admin.id) }
      let(:email) { preview.account_setup }

      it { expect(email.to).to eq [casa_admin.email] }
    end
 
    context "When passed ID is invalid" do
      let(:preview) {described_class.new(id: -1) }
      let(:email) { preview.account_setup }

      it { expect(email.to).to eq ["missing_casa_admin@example.com"] }
    end
  end

  describe "#deactivation" do
    context "When no ID is passed" do
      let(:preview) { described_class.new }
      let(:email) { preview.deactivation }

      it { expect(email.to).to eq [casa_admin.email] }
    end
     
     context "When passed ID is valid" do
      let(:preview) {described_class.new(id: casa_admin.id) }
      let(:email) { preview.deactivation }

      it { expect(email.to).to eq [casa_admin.email] }
    end
 
    context "When passed ID is invalid" do
      let(:preview) {described_class.new(id: -1) }
      let(:email) { preview.deactivation }

      it { expect(email.to).to eq ["missing_casa_admin@example.com"] }
    end
  end
end

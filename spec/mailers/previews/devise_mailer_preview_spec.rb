require "rails_helper"
require File.join(Rails.root, "lib", "mailers", "previews", "devise_mailer_preview")

RSpec.describe DeviseMailerPreview do
  let(:subject) { described_class.new }
  let!(:user) { create(:user) }

  describe "#reset_password_instructions" do
    context "When no ID is passed" do
      let(:preview) { described_class.new }
      let(:email) { preview.reset_password_instructions }

      it { expect(email.to).to eq [user.email] }
    end

    context "When passed ID is valid" do
      let(:preview) { described_class.new(id: user.id) }
      let(:email) { preview.reset_password_instructions }

      it { expect(email.to).to eq [user.email] }
    end

    context "When passed ID is invalid" do
      let(:preview) { described_class.new(id: -1) }
      let(:email) { preview.reset_password_instructions }

      it { expect(email.to).to eq ["missing_user@example.com"] }
    end
  end

  describe "#invitation_instructions_as_all_casa_admin" do
    let!(:all_casa_admin) { create(:all_casa_admin) }
    let(:message) { subject.invitation_instructions_as_all_casa_admin }

    it { expect(message.to).to eq [all_casa_admin.email] }
  end

  describe "#invitation_instructions_as_casa_admin" do
    let!(:casa_admin) { create(:casa_admin) }
    let(:message) { subject.invitation_instructions_as_casa_admin }

    it { expect(message.to).to eq [casa_admin.email] }
  end

  describe "#invitation_instructions_as_supervisor" do
    let!(:supervisor) { create(:supervisor) }
    let(:message) { subject.invitation_instructions_as_supervisor }

    it { expect(message.to).to eq [supervisor.email] }
  end

  describe "#invitation_instructions_as_volunteer" do
    let!(:volunteer) { create(:volunteer) }
    let(:message) { subject.invitation_instructions_as_volunteer }

    it { expect(message.to).to eq [volunteer.email] }
  end
end

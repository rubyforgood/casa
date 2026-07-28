require "rails_helper"
require Rails.root.join("lib/mailers/previews/devise_mailer_preview").to_s

RSpec.shared_examples "invitation instructions" do |factory|
  let!(:record) { create(factory) }
  let(:message) { subject.send(:"invitation_instructions_as_#{factory}") }

  it { expect(message.to).to eq [record.email] }
end

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
    it_behaves_like "invitation instructions", :all_casa_admin
  end

  describe "#invitation_instructions_as_casa_admin" do
    it_behaves_like "invitation instructions", :casa_admin
  end

  describe "#invitation_instructions_as_supervisor" do
    it_behaves_like "invitation instructions", :supervisor
  end

  describe "#invitation_instructions_as_volunteer" do
    it_behaves_like "invitation instructions", :volunteer
  end
end

require "rails_helper"
require File.join(Rails.root, "lib", "mailers", "previews", "volunteer_mailer_preview")

RSpec.describe VolunteerMailerPreview do
  let(:subject) { described_class.new }
  let!(:volunteer) { create(:volunteer) }
  let!(:supervisor) { create(:supervisor) }
  let!(:admin) { create(:casa_admin) }

  describe "#account_setup" do
    let(:message) { subject.account_setup }

    it { expect(message.to).to eq [volunteer.email] }
  end

  describe "#court_report_reminder" do
    let(:message) { subject.court_report_reminder }

    it { expect(message.to).to eq [volunteer.email] }
  end

  describe "#case_contacts_reminder" do
    let(:message) { subject.case_contacts_reminder }

    it { expect(message.to).to eq [volunteer.email] }
  end

  describe "#get_user" do
    context "uses a volunteer record" do
      context "when no id is provided" do
        let(:message) { subject.account_setup }

        it { expect(message.to).to eq [volunteer.email] }
      end

      context "when a volunteer id is provided" do
        let(:params) { {id: volunteer.id} }
        let(:subject) { described_class.new params }
        let(:message) { subject.account_setup }

        it { expect(message.to).to eq [volunteer.email] }
      end

      context "when a supervisor id is provided" do
        let(:params) { {id: supervisor.id} }
        let(:subject) { described_class.new params }
        let(:message) { subject.account_setup }

        it { expect(message.to).to eq [volunteer.email] }
      end

      context "when an admin id is provided" do
        let(:params) { {id: admin.id} }
        let(:subject) { described_class.new params }
        let(:message) { subject.account_setup }

        it { expect(message.to).to eq [volunteer.email] }
      end
    end
  end
end

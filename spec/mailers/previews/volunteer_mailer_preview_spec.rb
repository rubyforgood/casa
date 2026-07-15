require "rails_helper"
require Rails.root.join("lib/mailers/previews/volunteer_mailer_preview").to_s

RSpec.describe VolunteerMailerPreview do
  let!(:volunteer) { create(:volunteer) }

  describe "#account_setup" do
    context "When no ID is passed" do
      let(:preview) { described_class.new }
      let(:email) { preview.account_setup }

      it { expect(email.to).to eq [volunteer.email] }
    end

    context "When passed ID is valid" do
      let(:preview) { described_class.new(id: volunteer.id) }
      let(:email) { preview.account_setup }

      it { expect(email.to).to eq [volunteer.email] }
    end

    context "When passed ID is invalid" do
      let(:preview) { described_class.new(id: -1) }
      let(:email) { preview.account_setup }

      it { expect(email.to).to eq ["missing_volunteer@example.com"] }
    end
  end

  describe "#court_report_reminder" do
    context "When no ID is passed" do
      let(:preview) { described_class.new }
      let(:email) { preview.court_report_reminder }

      it { expect(email.to).to eq [volunteer.email] }
    end

    context "When passed ID is valid" do
      let(:preview) { described_class.new(id: volunteer.id) }
      let(:email) { preview.court_report_reminder }

      it { expect(email.to).to eq [volunteer.email] }
    end

    context "When passed ID is invalid" do
      let(:preview) { described_class.new(id: -1) }
      let(:email) { preview.court_report_reminder }

      it { expect(email.to).to eq ["missing_volunteer@example.com"] }
    end
  end

  describe "#case_contacts_reminder" do
    context "When no ID is passed" do
      let(:preview) { described_class.new }
      let(:email) { preview.case_contacts_reminder }

      it { expect(email.to).to eq [volunteer.email] }
    end

    context "When passed ID is valid" do
      let(:preview) { described_class.new(id: volunteer.id) }
      let(:email) { preview.case_contacts_reminder }

      it { expect(email.to).to eq [volunteer.email] }
    end

    context "When passed ID is invalid" do
      let(:preview) { described_class.new(id: -1) }
      let(:email) { preview.case_contacts_reminder }

      it { expect(email.to).to eq ["missing_volunteer@example.com"] }
    end
  end

  describe "#reimbursement_complete_email" do
    let!(:case_contact) { create(:case_contact, :wants_reimbursement, creator: volunteer) }

    context "When no ID is passed" do
      let(:preview) { described_class.new }
      let(:email) { preview.reimbursement_complete_email }

      it { expect(email.to).to eq [volunteer.email] }
    end

    context "When passed ID is valid" do
      let(:preview) { described_class.new(id: volunteer.id) }
      let(:email) { preview.reimbursement_complete_email }

      it { expect(email.to).to eq [volunteer.email] }
    end

    context "When passed ID is invalid" do
      let(:preview) { described_class.new(id: -1) }
      let(:email) { preview.reimbursement_complete_email }

      it { expect(email.to).to eq ["missing_volunteer@example.com"] }
    end

    context "When the volunteer has no case contact wanting reimbursement" do
      let(:other_volunteer) { create(:volunteer) }
      let(:preview) { described_class.new(id: other_volunteer.id) }
      let(:email) { preview.reimbursement_complete_email }

      it "does not fall back to a different volunteer's case contact" do
        expect(email.to).to eq ["missing_case_contact@example.com"]
      end
    end
  end
end

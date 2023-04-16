require "rails_helper"
require File.join(Rails.root, "lib", "mailers", "previews", "volunteer_mailer_preview")

RSpec.describe VolunteerMailerPreview do
  let!(:volunteer) { create(:volunteer) }

  describe "#account_setup" do
    context "When no ID is passed" do
      let(:preview) { described_class.new }
      let(:email) { preview.account_setup }

      it { expect(email.to).to eq [volunteer.email] }
    end
     
     context "When passed ID is valid" do
      let(:preview) {described_class.new(id: volunteer.id) }
      let(:email) { preview.account_setup }

      it { expect(email.to).to eq [volunteer.email] }
    end
 
    context "When passed ID is invalid" do
      let(:preview) {described_class.new(id: -1) }
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
      let(:preview) {described_class.new(id: volunteer.id) }
      let(:email) { preview.court_report_reminder }

      it { expect(email.to).to eq [volunteer.email] }
    end
 
    context "When passed ID is invalid" do
      let(:preview) {described_class.new(id: -1) }
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
      let(:preview) {described_class.new(id: volunteer.id) }
      let(:email) { preview.case_contacts_reminder }

      it { expect(email.to).to eq [volunteer.email] }
    end
 
    context "When passed ID is invalid" do
      let(:preview) {described_class.new(id: -1) }
      let(:email) { preview.case_contacts_reminder }

      it { expect(email.to).to eq ["missing_volunteer@example.com"] }
    end
  end
end

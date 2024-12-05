require "rails_helper"

RSpec.describe NotificationPolicy, type: :policy do
  subject { described_class }

  let(:recipient) { create(:volunteer) }
  let(:casa_admin) { create(:casa_admin) }
  let(:volunteer) { build(:volunteer) }
  let(:supervisor) { build(:supervisor) }

  permissions :index? do
    it "allows any volunteer" do
      expect(subject).to permit(casa_admin)
    end

    it "allows any supervisor" do
      expect(subject).to permit(supervisor)
    end

    it "allows any admin" do
      expect(subject).to permit(volunteer)
    end
  end

  permissions :mark_as_read? do
    let(:notification) { create(:notification, recipient: recipient) }

    it "allows recipient" do
      expect(subject).to permit(recipient, notification)
    end

    it "does not allow other volunteer" do
      expect(subject).not_to permit(volunteer, notification)
    end

    it "does not permit other supervisor" do
      expect(subject).not_to permit(supervisor, notification)
    end

    it "does not permit other admin" do
      expect(subject).not_to permit(casa_admin, notification)
    end
  end
end

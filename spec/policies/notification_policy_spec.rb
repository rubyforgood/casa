require "rails_helper"

RSpec.describe NotificationPolicy, type: :policy do
  subject { described_class }

  let(:recipient) { create(:volunteer) }
  let(:casa_admin) { create(:casa_admin) }
  let(:volunteer) { build(:volunteer) }
  let(:supervisor) { build(:supervisor) }

  permissions :index? do
    it "allows any volunteer" do
      is_expected.to permit(casa_admin)
    end

    it "allows any supervisor" do
      is_expected.to permit(supervisor)
    end

    it "allows any admin" do
      is_expected.to permit(volunteer)
    end
  end

  permissions :mark_as_read? do
    let(:notification) { create(:notification, recipient: recipient) }

    it "allows recipient" do
      is_expected.to permit(recipient, notification)
    end

    it "does not allow other volunteer" do
      is_expected.to_not permit(volunteer, notification)
    end

    it "does not permit other supervisor" do
      is_expected.to_not permit(supervisor, notification)
    end

    it "does not permit other admin" do
      is_expected.to_not permit(casa_admin, notification)
    end
  end
end

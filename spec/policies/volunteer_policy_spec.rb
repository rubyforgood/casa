require "rails_helper"

RSpec.describe DashboardPolicy do
  subject { described_class }

  permissions :update_volunteer_email? do
    context "when user is a supervisor" do
      it "does not permit the user to update volunteer email" do
        supervisor = create(:user, :supervisor)
        expect(Pundit.policy(supervisor, :volunteer).update_volunteer_email?).to eq false
      end
    end

    context "when user is an admin" do
      it "permits the user to update volunteer email" do
        admin = create(:user, :casa_admin)
        expect(Pundit.policy(admin, :volunteer).update_volunteer_email?).to eq true
      end
    end
  end
end

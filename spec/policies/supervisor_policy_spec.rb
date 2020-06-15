require "rails_helper"

RSpec.describe SupervisorPolicy do
  subject { described_class }

  permissions :update_supervisor_email? do
    context "when user is an admin or is the record" do
      it "permits an admin to update supervisor email" do
        admin = create(:user, :casa_admin)
        expect(Pundit.policy(admin, :supervisor).update_supervisor_email?).to eq true
      end

      it "permits the supervisor to update their own email" do
        supervisor = create(:user, :supervisor)
        expect(Pundit.policy(supervisor, :supervisor).update_supervisor_email?).to eq true
      end
    end

    context "when user is not an admin or the record" do
      it "does not permit the user to update volunteer email" do
        volunteer = create(:user, :volunteer)
        expect(Pundit.policy(volunteer, :supervisor).update_supervisor_email?).to eq false
      end
    end

  end
end

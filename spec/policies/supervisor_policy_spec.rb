require "rails_helper"

RSpec.describe "Supervisor Policy" do
  subject { described_class }

  permissions :update_supervisor_email? do
    context "when user is an admin or is the record" do
      it "permits an admin to update supervisor email" do
        admin = create(:casa_admin)
        supervisor = create(:supervisor)
        expect(Pundit.policy(admin, supervisor).update_supervisor_email?).to eq true
      end

      it "permits the supervisor to update their own email" do
        supervisor = create(:supervisor)
        expect(Pundit.policy(supervisor, supervisor).update_supervisor_email?).to eq true
      end
    end

    context "when user is not an admin or the record" do
      it "does not permit the other supervisor user to update volunteer email" do
        supervisor1 = create(:supervisor)
        supervisor2 = create(:supervisor)
        expect(Pundit.policy(supervisor1, supervisor2).update_supervisor_email?).to eq false
      end

      it "does not permit the volunteer user to update volunteer email" do
        volunteer = create(:volunteer)
        supervisor = create(:supervisor)
        expect(Pundit.policy(volunteer, supervisor).update_supervisor_email?).to eq false
      end
    end
  end

  permissions :index? do
    context "when user is an admin" do
      it "has access to the supervisors index action" do
        user = create :casa_admin

        expect(Pundit.policy(user, Supervisor).index?).to be true
      end
    end

    context "when user is a supervisor" do
      it "has access to the supervisors index action" do
        user = create :supervisor

        expect(Pundit.policy(user, Supervisor).index?).to be true
      end
    end

    context "when user is a volunteer" do
      it "does not have access to the supervisors index action" do
        user = create :volunteer

        expect(Pundit.policy(user, Supervisor).index?).to be false
      end
    end
  end

  permissions :create? do
    it "allows admins to create supervisors" do
      user = create :casa_admin

      expect(Pundit.policy(user, Supervisor).create?).to be true
    end

    it "does not allow supervisors to create supervisors" do
      user = create :supervisor

      expect(Pundit.policy(user, Supervisor).create?).to be false
    end

    it "does not allow volunteers to create supervisors" do
      user = create :supervisor

      expect(Pundit.policy(user, Supervisor).create?).to be false
    end
  end
end

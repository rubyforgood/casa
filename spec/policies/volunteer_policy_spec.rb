require "rails_helper"

RSpec.describe VolunteerPolicy do
  subject { described_class }

  permissions :update_volunteer_email? do
    context "when user is a supervisor" do
      it "does not permit the user to update volunteer email" do
        supervisor = create(:supervisor)
        expect(Pundit.policy(supervisor, :volunteer).update_volunteer_email?).to eq false
      end
    end

    context "when user is an admin" do
      it "permits the user to update volunteer email" do
        admin = create(:casa_admin)
        expect(Pundit.policy(admin, :volunteer).update_volunteer_email?).to eq true
      end
    end
  end

  permissions :create?, :new? do
    context "when user is a casa admin" do
      let(:admin) { create(:casa_admin) }
      it "allows" do
        expect(subject).to permit(admin, :volunteer)
      end
    end

    context "when user is a supervisor" do
      let(:supervisor) { create(:supervisor) }
      it "does not permit" do
        expect(subject).not_to permit(supervisor, :volunteer)
      end
    end

    context "when user is a volunteer" do
      let(:volunteer) { create(:volunteer) }
      it "does not permit" do
        expect(subject).not_to permit(volunteer, :volunteer)
      end
    end
  end
end

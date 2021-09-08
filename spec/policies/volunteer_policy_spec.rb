require "rails_helper"

RSpec.describe VolunteerPolicy do
  subject { described_class }

  let(:admin) { build_stubbed(:casa_admin) }
  let(:supervisor) { build_stubbed(:supervisor) }
  let(:volunteer) { build_stubbed(:volunteer) }

  permissions :index?, :datatable?, :edit?, :update?, :activate?, :deactivate?, :create?, :new? do
    context "when user is a casa admin" do
      it "allows" do
        is_expected.to permit(admin)
      end
    end

    context "when user is a supervisor" do
      it "allows" do
        is_expected.to permit(supervisor)
      end
    end

    context "when user is a volunteer" do
      it "does not permit" do
        is_expected.not_to permit(volunteer)
      end
    end
  end

  permissions :update_volunteer_email? do
    context "when user is a casa admin" do
      it "allows" do
        is_expected.to permit(admin)
      end
    end

    context "when user is a supervisor" do
      it "does not permit" do
        is_expected.to permit(supervisor)
      end
    end

    context "when user is a volunteer" do
      it "does not permit" do
        is_expected.not_to permit(volunteer)
      end
    end
  end

  describe "VolunteerPolicy::Scope" do
    describe "#resolve" do
      subject { described_class::Scope.new(user, Volunteer.all).resolve }

      let!(:volunteer1) { create(:volunteer, casa_org: casa_org) }
      let!(:another_org_volunteer) { create(:volunteer, casa_org: another_casa_org) }

      let(:casa_org) { create(:casa_org) }
      let(:another_casa_org) { create(:casa_org) }

      context "when admin" do
        let(:user) { build_stubbed(:casa_admin, casa_org: casa_org) }

        it { is_expected.to include(volunteer1) }
        it { is_expected.not_to include(another_org_volunteer) }
      end

      context "when supervisor" do
        let(:user) { build_stubbed(:supervisor, casa_org: casa_org) }

        it { is_expected.to include(volunteer1) }
        it { is_expected.not_to include(another_org_volunteer) }
      end

      context "when volunteer" do
        let(:user) { build_stubbed(:volunteer, casa_org: casa_org) }

        it { is_expected.to include(volunteer1) }
        it { is_expected.not_to include(another_org_volunteer) }
      end
    end
  end
end

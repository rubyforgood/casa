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
end

require "rails_helper"

RSpec.describe VolunteerPolicy do
  subject { described_class }

  let(:admin) { create(:casa_admin) }
  let(:supervisor) { create(:supervisor) }
  let(:volunteer) { create(:volunteer) }

  permissions :create?, :new?, :update_volunteer_email? do
    context "when user is a casa admin" do
      it "allows" do
        is_expected.to permit(admin, :volunteer)
      end
    end

    context "when user is a supervisor" do
      it "does not permit" do
        is_expected.not_to permit(supervisor, :volunteer)
      end
    end

    context "when user is a volunteer" do
      it "does not permit" do
        is_expected.not_to permit(volunteer, :volunteer)
      end
    end
  end
end

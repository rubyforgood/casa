require "rails_helper"

RSpec.describe LanguagePolicy do
  subject { described_class }

  let(:admin) { build_stubbed(:casa_admin) }
  let(:supervisor) { build_stubbed(:supervisor) }
  let(:volunteer) { build_stubbed(:volunteer) }

  permissions :add_language?, :remove_from_volunteer? do
    context "when user is a casa admin" do
      it "doesn't permit" do
        expect(subject).not_to permit(admin)
      end
    end

    context "when user is a supervisor" do
      it "doesn't permit" do
        expect(subject).not_to permit(supervisor)
      end
    end

    context "when user is a volunteer" do
      it "allows" do
        expect(subject).to permit(volunteer)
      end
    end
  end
end

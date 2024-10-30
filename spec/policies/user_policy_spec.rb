require "rails_helper"

RSpec.describe UserPolicy, :aggregate_failures do
  subject { described_class }

  let(:casa_org) { build_stubbed :casa_org }
  let(:casa_admin) { build_stubbed :casa_admin, casa_org: }
  let(:supervisor) { build_stubbed :supervisor, casa_org: }
  let(:volunteer) { build_stubbed :volunteer, casa_org: }
  let(:supervised_volunteer) { build_stubbed :volunteer, supervisor:, casa_org: }

  let(:other_org) { build_stubbed :casa_org }
  let(:other_org_admin) { build_stubbed :casa_admin, casa_org: other_org }
  let(:other_org_supervisor) { build_stubbed :supervisor, casa_org: other_org }
  let(:other_org_volunteer) { build_stubbed :volunteer, casa_org: other_org }

  # ! TODO: ! ANY User edit ANY user! ???
  permissions :edit?, :update?, :update_email?, :update_password? do
    it "allows any user to edit any other user", :aggregate_failures do # rubocop:todo RSpec/ExampleLength
      expect(subject).to permit(casa_admin, casa_admin)
      expect(subject).to permit(casa_admin, supervisor)
      expect(subject).to permit(casa_admin, volunteer)
      expect(subject).to permit(casa_admin, other_org_admin)
      expect(subject).to permit(casa_admin, other_org_supervisor)
      expect(subject).to permit(casa_admin, other_org_volunteer)

      expect(subject).to permit(supervisor, casa_admin)
      expect(subject).to permit(supervisor, supervisor)
      expect(subject).to permit(supervisor, volunteer)
      expect(subject).to permit(supervisor, supervised_volunteer)
      expect(subject).to permit(supervisor, other_org_admin)
      expect(subject).to permit(supervisor, other_org_supervisor)
      expect(subject).to permit(supervisor, other_org_volunteer)

      expect(subject).to permit(volunteer, casa_admin)
      expect(subject).to permit(volunteer, supervisor)
      expect(subject).to permit(volunteer, volunteer)
      expect(subject).to permit(volunteer, other_org_admin)
      expect(subject).to permit(volunteer, other_org_supervisor)
      expect(subject).to permit(volunteer, other_org_volunteer)
    end
  end

  permissions :update_user_setting? do
    it "allows update settings of all roles" do # rubocop:disable RSpec/ExampleLength
      expect(subject).to permit(casa_admin, casa_admin)
      expect(subject).to permit(casa_admin, supervisor)
      expect(subject).to permit(casa_admin, volunteer)
      # TODO: shold not access other org records!

      expect(subject).to permit(casa_admin, other_org_admin)
      expect(subject).to permit(casa_admin, other_org_supervisor)
      expect(subject).to permit(casa_admin, other_org_volunteer)

      expect(subject).not_to permit(supervisor, casa_admin)
      expect(subject).to permit(supervisor, supervisor)
      expect(subject).to permit(supervisor, volunteer)
      expect(subject).not_to permit(supervisor, other_org_admin)
      expect(subject).not_to permit(supervisor, other_org_supervisor)
      expect(subject).not_to permit(supervisor, other_org_volunteer)

      expect(subject).not_to permit(volunteer, casa_admin)
      expect(subject).not_to permit(volunteer, supervisor)
      expect(subject).not_to permit(volunteer, volunteer)
    end
  end

  permissions :add_language?, :remove_language? do
    specify do # rubocop:disable RSpec/ExampleLength
      expect(subject).to permit(casa_admin, casa_admin)
      expect(subject).to permit(casa_admin, supervisor)
      expect(subject).to permit(casa_admin, volunteer)
      expect(subject).not_to permit(casa_admin, other_org_admin)
      expect(subject).not_to permit(casa_admin, other_org_supervisor)
      expect(subject).not_to permit(casa_admin, other_org_volunteer)

      expect(subject).to permit(supervisor, casa_admin)
      expect(subject).to permit(supervisor, supervisor)
      expect(subject).to permit(supervisor, volunteer)
      expect(subject).to permit(supervisor, supervised_volunteer)
      expect(subject).not_to permit(supervisor, other_org_admin)
      expect(subject).not_to permit(supervisor, other_org_supervisor)
      expect(subject).not_to permit(supervisor, other_org_volunteer)

      expect(subject).not_to permit(volunteer, casa_admin)
      expect(subject).not_to permit(volunteer, supervisor)
      expect(subject).to permit(volunteer, volunteer)
      expect(subject).not_to permit(volunteer, other_org_admin)
      expect(subject).not_to permit(volunteer, other_org_supervisor)
      expect(subject).not_to permit(volunteer, other_org_volunteer)
    end
  end
end

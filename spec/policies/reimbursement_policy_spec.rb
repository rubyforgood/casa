require "rails_helper"

RSpec.describe ReimbursementPolicy do
  subject { described_class }

  let(:casa_admin) { build_stubbed(:casa_admin) }
  let(:volunteer) { build_stubbed(:volunteer) }
  let(:supervisor) { build_stubbed(:supervisor) }

  permissions :index?, :change_complete_status? do
    it { is_expected.to permit(casa_admin) }
    it { is_expected.to_not permit(supervisor) }
    it { is_expected.to_not permit(volunteer) }
  end
end

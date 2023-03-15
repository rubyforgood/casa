require "rails_helper"

RSpec.describe CaseCourtOrderPolicy do
  subject { described_class }

  let(:casa_admin) { build_stubbed(:casa_admin) }
  let(:supervisor) { build_stubbed(:supervisor) }
  let(:volunteer) { build_stubbed(:volunteer) }

  permissions :destroy? do
    it { is_expected.to permit(casa_admin) }
    it { is_expected.to permit(supervisor) }
    it { is_expected.to permit(volunteer) }
  end
end

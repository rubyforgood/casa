require "rails_helper"

RSpec.describe Supervisor, type: :model do
  describe "#role" do
    subject(:supervisor) { create :supervisor }

    it { expect(supervisor.role).to eq "Supervisor" }

    it { is_expected.to have_many(:supervisor_volunteers) }
    it { is_expected.to have_many(:active_supervisor_volunteers) }
    it { is_expected.to have_many(:unassigned_supervisor_volunteers) }
    it { is_expected.to have_many(:volunteers).through(:active_supervisor_volunteers) }
    it { is_expected.to have_many(:volunteers_ever_assigned).through(:supervisor_volunteers) }
  end
end

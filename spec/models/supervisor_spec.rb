require "rails_helper"

RSpec.describe Supervisor, type: :model do
  describe "#role" do
    subject(:supervisor) { create :supervisor }

    it { expect(supervisor.role).to eq "Supervisor" }
  end
end

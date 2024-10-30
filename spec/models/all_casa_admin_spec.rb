require "rails_helper"

RSpec.describe AllCasaAdmin do
  describe "#role" do
    subject(:all_casa_admin) { build_stubbed :all_casa_admin }

    it { expect(all_casa_admin.role).to eq "All Casa Admin" }
  end
end

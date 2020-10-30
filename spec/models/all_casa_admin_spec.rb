require "rails_helper"

RSpec.describe AllCasaAdmin, type: :model do
  describe "#role" do
    subject(:all_casa_admin) { create :all_casa_admin }

    it { expect(all_casa_admin.role).to eq "All Casa Admin" }
  end
end

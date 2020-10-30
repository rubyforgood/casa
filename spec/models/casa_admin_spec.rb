require "rails_helper"

RSpec.describe CasaAdmin, type: :model do
  describe "#deactivate" do
    let(:casa_admin) { create(:casa_admin) }

    it "deactivates the casa admin" do
      casa_admin.deactivate

      casa_admin.reload
      expect(casa_admin.active).to eq(false)
    end

    it "activates the casa admin" do
      casa_admin.active = false
      casa_admin.save
      casa_admin.activate

      casa_admin.reload
      expect(casa_admin.active).to eq(true)
    end
  end

  describe "#role" do
    subject(:admin) { create :casa_admin }

    it { expect(admin.role).to eq "Casa Admin" }
  end
end

require "rails_helper"

RSpec.describe CasaAdmin, type: :model do
  describe "#deactivate" do
    let(:casa_admin) { create(:casa_admin) }

    it "deactivates the volunteer" do
      casa_admin.deactivate

      casa_admin.reload
      expect(casa_admin.active).to eq(false)
    end
  end
end

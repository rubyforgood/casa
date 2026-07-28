require "rails_helper"

RSpec.describe Roles, type: :model do
  describe "#role" do
    it "returns the titleized model name for each user type" do
      expect(build(:volunteer).role).to eq "Volunteer"
      expect(build(:supervisor).role).to eq "Supervisor"
      expect(build(:casa_admin).role).to eq "Casa Admin"
    end

    it "returns the titleized model name for an all casa admin" do
      expect(build(:all_casa_admin).role).to eq "All Casa Admin"
    end
  end
end

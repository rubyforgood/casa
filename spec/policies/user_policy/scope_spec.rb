require "rails_helper"

RSpec.describe UserPolicy::Scope do
  describe "#resolve" do
    it "returns all Users when user is admin" do
      admin = create(:casa_admin)

      scope = described_class.new(admin, User)

      expect(scope.resolve).to contain_exactly(admin)
    end

    it "returns the user when user is volunteer" do
      user = create(:volunteer)

      scope = described_class.new(user, User)

      expect(scope.resolve).to eq [user]
    end
  end
end

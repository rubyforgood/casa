require 'rails_helper'

RSpec.describe UserPolicy::Scope, "#resolve" do
  it "returns all Users when user is admin" do
    admin = create(:user, :casa_admin)
    user1 = create(:user)
    user2 = create(:user)

    scope = UserPolicy::Scope.new(admin, User)

    expect(scope.resolve).to contain_exactly(admin, user1, user2)
  end

  it "returns the user when user is volunteer" do
    user = create(:user, :volunteer)

    scope = UserPolicy::Scope.new(user, User)

    expect(scope.resolve).to eq [user]
  end
end

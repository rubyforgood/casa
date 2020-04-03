require "rails_helper"

RSpec.describe CasaCasePolicy::Scope, "#resolve" do
  it "returns all CasaCases when user is admin" do
    user = create(:user, :casa_admin)
    all_casa_cases = create_list(:casa_case, 2)

    scope = CasaCasePolicy::Scope.new(user, CasaCase)

    expect(scope.resolve).to eq all_casa_cases
  end

  it "returns empty array when user is volunteer" do
    user = create(:user, :volunteer)
    all_casa_cases = create_list(:casa_case, 2)

    scope = CasaCasePolicy::Scope.new(user, CasaCase)

    expect(scope.resolve).to eq []
  end
end

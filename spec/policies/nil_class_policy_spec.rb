require "rails_helper"

RSpec.describe NilClassPolicy do
  subject { described_class }

  it "doesn't permit any actions" do
    policy = NilClassPolicy.new(nil, nil)

    expect(policy.index?).to be_falsey
    expect(policy.show?).to be_falsey
    expect(policy.create?).to be_falsey
    expect(policy.new?).to be_falsey
    expect(policy.update?).to be_falsey
    expect(policy.edit?).to be_falsey
    expect(policy.destroy?).to be_falsey
  end
end

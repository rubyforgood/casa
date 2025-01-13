require "rails_helper"

RSpec.describe NilClassPolicy do
  subject { described_class.new(nil, nil) }

  it "doesn't permit any actions" do
    expect(subject.index?).to be_falsey
    expect(subject.show?).to be_falsey
    expect(subject.create?).to be_falsey
    expect(subject.new?).to be_falsey
    expect(subject.update?).to be_falsey
    expect(subject.edit?).to be_falsey
    expect(subject.destroy?).to be_falsey
  end
end

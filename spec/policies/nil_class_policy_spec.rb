require "rails_helper"

RSpec.describe NilClassPolicy do
  subject { described_class.new(nil, nil) }

  it "doesn't permit index action" do
    expect(subject.index?).to be_falsey
  end

  it "doesn't permit show action" do
    expect(subject.show?).to be_falsey
  end

  it "doesn't permit create action" do
    expect(subject.create?).to be_falsey
  end

  it "doesn't permit new action" do
    expect(subject.new?).to be_falsey
  end

  it "doesn't permit update action" do
    expect(subject.update?).to be_falsey
  end

  it "doesn't permit edit action" do
    expect(subject.edit?).to be_falsey
  end

  it "doesn't permit destroy action" do
    expect(subject.destroy?).to be_falsey
  end
end

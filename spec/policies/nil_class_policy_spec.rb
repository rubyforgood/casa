require "rails_helper"

RSpec.describe NilClassPolicy do
  subject { described_class.new(nil, nil) }

  it "doesn't permit index action" do
    expect(subject).not_to be_index
  end

  it "doesn't permit show action" do
    expect(subject).not_to be_show
  end

  it "doesn't permit create action" do
    expect(subject).not_to be_create
  end

  it "doesn't permit new action" do
    expect(subject).not_to be_new
  end

  it "doesn't permit update action" do
    expect(subject).not_to be_update
  end

  it "doesn't permit edit action" do
    expect(subject).not_to be_edit
  end

  it "doesn't permit destroy action" do
    expect(subject).not_to be_destroy
  end
end

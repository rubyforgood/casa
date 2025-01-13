require "rails_helper"

RSpec.describe NilClassPolicy do
  subject { described_class }

  it "doesn't permit" do
    expect(subject).not_to permit(nil)
  end
end

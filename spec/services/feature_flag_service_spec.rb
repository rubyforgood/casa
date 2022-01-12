require "rails_helper"

RSpec.describe FeatureFlagService do
  it "can be enabled and disabled" do
    expect(described_class.is_enabled?(FeatureFlagService::SOME_FLAG)).to be_falsey
    described_class.enable!(FeatureFlagService::SOME_FLAG)
    expect(described_class.is_enabled?(FeatureFlagService::SOME_FLAG)).to be_truthy
    described_class.disable!(FeatureFlagService::SOME_FLAG)
    expect(described_class.is_enabled?(FeatureFlagService::SOME_FLAG)).to be_falsey
  end
end

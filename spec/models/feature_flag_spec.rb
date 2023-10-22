require "rails_helper"

RSpec.describe FeatureFlag, type: :model do
  context "When creating a new feature flag" do
    it "raises an exception for duplicated feature flag name" do
      duplicate_feature_flag_name = "feature name"

      expect {
        create(:feature_flag, name: duplicate_feature_flag_name)
        create(:feature_flag, name: duplicate_feature_flag_name)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end

require "rails_helper"

RSpec.describe "patch_notes/index", type: :view do
  let(:all_casa_admin) { build(:all_casa_admin) }

  before(:each) { sign_in all_casa_admin }

  describe "the feature flag list" do
    it "displays the feature flags with toggles" do
      feature_flag_1 = create(:feature_flag, name: "Test feature one")
      feature_flag_2 = create(:feature_flag, name: "Test feature two")
      assign(:feature_flags, [feature_flag_1, feature_flag_2])

      render template: "all_casa_admins/feature_flags/index"

      expect(rendered).to include("Test feature one")
      expect(rendered).to include("Test feature two")
    end
  end
end

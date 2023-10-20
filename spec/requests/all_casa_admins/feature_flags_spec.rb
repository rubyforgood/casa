require "rails_helper"

RSpec.describe "/all_casa_admins/feature_flags", type: :request do
  let(:all_casa_admin) { build(:all_casa_admin) }
  let(:feature_flag) { create(:feature_flag) }

  before(:each) { sign_in all_casa_admin }

  describe "GET /index" do
    it "gets all the feature flags" do
      get all_casa_admins_feature_flags_path

      expect(response).to render_template(:index)
      expect(response).to be_successful
    end
  end

  describe "PATCH /update" do
    it "updates enable to false on toggle" do
      patch "/all_casa_admins/feature_flags/#{feature_flag.id}"

      feature_flag.reload
      expect(feature_flag.enabled).to eq(false)
    end
  end
end

require "rails_helper"

RSpec.describe "/settings", type: :request do
  let(:admin) { create(:casa_admin) }

  describe "GET /index" do
    it "renders a successful response" do
      sign_in admin

      get settings_path
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    before do
      sign_in admin
    end

    context "with show_additional_expense param" do
      let(:params) do
        {
          show_additional_expenses: 'true'
        }
      end

      it "enables the show additional expense flag" do
        FeatureFlagService.disable!(FeatureFlagService::SHOW_ADDITIONAL_EXPENSES_FLAG)
        post settings_path, params: params
        expect(FeatureFlagService.is_enabled?(FeatureFlagService::SHOW_ADDITIONAL_EXPENSES_FLAG)).to be true
      end
    end

    context "without show_additional_expense param" do
      let(:params) do
        { }
      end

      it "enables the show additional expense flag" do
        FeatureFlagService.enable!(FeatureFlagService::SHOW_ADDITIONAL_EXPENSES_FLAG)
        post settings_path, params: params
        expect(FeatureFlagService.is_enabled?(FeatureFlagService::SHOW_ADDITIONAL_EXPENSES_FLAG)).to be false
      end
    end
  end
end
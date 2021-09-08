require "rails_helper"

RSpec.describe "all_casa_admins/casa_orgs/show", type: :view do
  context "All casa admin organization dashboard" do
    let(:organization) { create :casa_org }
    let(:user) { build_stubbed(:all_casa_admin) }
    let(:metrics) {
      {
        "metric name 1" => 1,
        "metric name 2" => 2
      }
    }

    before do
      allow(view).to receive(:current_user).and_return(user)
      allow(view).to receive(:selected_organization).and_return(organization)
      assign :casa_org_metrics, metrics
      render
    end

    it "shows new admin button" do
      expect(rendered).to have_text("New CASA Admin")
    end

    it "shows metrics" do
      expect(rendered).to have_text("metric name 1: 1")
      expect(rendered).to have_text("metric name 2: 2")
    end
  end
end

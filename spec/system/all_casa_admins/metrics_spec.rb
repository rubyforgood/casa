require "rails_helper"

RSpec.describe "all-CASA metrics", type: :system do
  let(:all_casa_admin) { create(:all_casa_admin) }

  before { sign_in all_casa_admin }

  it "is reachable from the sidebar and shows the platform charts" do
    visit authenticated_all_casa_admin_root_path
    expect(page).to have_link("Metrics")

    click_link "Metrics"

    expect(page).to have_current_path(all_casa_admins_metrics_path, ignore_query: true)
    expect(page).to have_css("h1", text: "Metrics")
    expect(page).to have_text("Case contacts logged")
    expect(page).to have_text("Monthly active users")
  end
end

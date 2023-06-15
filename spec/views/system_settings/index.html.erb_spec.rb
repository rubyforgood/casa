require "rails_helper"

RSpec.describe "System Settings", type: :view do
  let(:admin) { build_stubbed :casa_admin }

  before do
    enable_pundit(view, admin)
    allow(view).to receive(:current_user).and_return(admin)
    sign_in admin
  end

  it "has a Feature Toggles menu option" do
    render template: "system_settings/index"
    expect(rendered).to have_text("Feature Toggles")
  end
end

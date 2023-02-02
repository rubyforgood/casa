require "rails_helper"

RSpec.describe "layout/sidebar", type: :view do
  before do
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:current_role).and_return(user.role)
  end

  context "when logged in as a casa admin" do
    let(:user) { build_stubbed :casa_admin }

    it "renders display name" do
      sign_in user

      render partial: "layouts/header"

      expect(rendered).to match CGI.escapeHTML user.display_name
    end
  end
end

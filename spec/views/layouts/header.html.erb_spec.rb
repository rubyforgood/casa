require "rails_helper"

RSpec.describe "layout/sidebar", type: :view do
  before do
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:current_role).and_return(user.role)
  end

  context "when logged in as a casa admin" do
    let(:user) { build_stubbed :casa_admin }

    it "renders user information", :aggregate_failures do
      sign_in user

      render partial: "layouts/header"

      expect(rendered).to match '<strong>Role: Casa Admin</strong>'
      expect(rendered).to match CGI.escapeHTML user.display_name
      expect(rendered).to match CGI.escapeHTML user.email
    end
  end

  context "when logged in as a supervisor" do
    let(:user) { build_stubbed :supervisor }

    it "renders user information", :aggregate_failures do
      sign_in user

      render partial: "layouts/header"

      expect(rendered).to match '<strong>Role: Supervisor</strong>'
      expect(rendered).to match CGI.escapeHTML user.display_name
      expect(rendered).to match CGI.escapeHTML user.email
    end
  end

  context "when logged in as a volunteer" do
    let(:user) { build_stubbed :volunteer }

    it "renders user information", :aggregate_failures do
      sign_in user

      render partial: "layouts/header"

      expect(rendered).to match '<strong>Role: Volunteer</strong>'
      expect(rendered).to match CGI.escapeHTML user.display_name
      expect(rendered).to match CGI.escapeHTML user.email
    end
  end
end

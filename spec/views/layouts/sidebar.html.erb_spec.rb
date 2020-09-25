require "rails_helper"

describe "layout/sidebar", type: :view do
  before do
    enable_pundit(view, user)
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:current_organization).and_return(user.casa_org)
    allow(view).to receive(:user_signed_in?).and_return(true)

    assign :casa_org, user.casa_org
  end

  context "when logged in as an admin" do
    let(:user) { build_stubbed :casa_admin }

    it "renders the 'Supervisors' menu item" do
      sign_in user

      render partial: "layouts/sidebar"

      expect(rendered).to have_link("Supervisors", href: "/supervisors")
    end
  end

  context "when logged in as a supervisor" do
    let(:user) { build_stubbed :supervisor }

    it "renders the 'Supervisors' menu item" do
      sign_in user

      render partial: "layouts/sidebar"

      expect(rendered).to have_link("Supervisors", href: "/supervisors")
    end
  end

  context "when logged in as a volunteer" do
    let(:user) { build_stubbed :volunteer }

    it "does not render the 'Supervisors' menu item" do
      sign_in user

      render partial: "layouts/sidebar"

      expect(rendered).to_not have_link("Supervisors", href: "/supervisors")
    end
  end
end

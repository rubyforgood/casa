require "rails_helper"

describe "layout/sidebar", type: :view do
  before do
    enable_pundit(view, user)
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:user_signed_in?).and_return(true)
    allow(view).to receive(:current_role).and_return(user.role)
    allow(view).to receive(:current_organization).and_return(user.casa_org)

    assign :casa_org, user.casa_org
  end

  context "when logged in as a supervisor" do
    let(:user) { build_stubbed :supervisor }

    it "renders the correct Role name on the sidebar" do
      sign_in user

      render partial: "layouts/sidebar"

      expect(rendered).to match '<span class="value">Supervisor</span>'
    end

    it "renders only menu items visible by supervisors" do
      sign_in user

      render partial: "layouts/sidebar"

      expect(rendered).to have_link("Supervisors", href: "/supervisors")
      expect(rendered).to have_link("Volunteers", href: "/volunteers")
      expect(rendered).to have_link("Cases", href: "/casa_cases")
      expect(rendered).to have_link("Case Contacts", href: "/case_contacts")
      expect(rendered).to_not have_link("Admins", href: "/casa_admins")
    end
  end

  context "when logged in as a volunteer" do
    let(:user) { build_stubbed :volunteer }

    it "renders the correct Role name on the sidebar" do
      sign_in user

      render partial: "layouts/sidebar"

      expect(rendered).to match '<span class="value">Volunteer</span>'
    end

    it "renders only menu items visible by volunteers" do
      sign_in user

      render partial: "layouts/sidebar"

      expect(rendered).to have_link("My Cases", href: "/casa_cases")
      expect(rendered).to have_link("Case Contacts", href: "/case_contacts")
      expect(rendered).to_not have_link("Volunteers", href: "/volunteers")
      expect(rendered).to_not have_link("Supervisors", href: "/supervisors")
      expect(rendered).to_not have_link("Admins", href: "/casa_admins")
    end
  end

  context "when logged in as a casa admin" do
    let(:user) { build_stubbed :casa_admin }

    it "renders the correct Role name on the sidebar" do
      sign_in user

      render partial: "layouts/sidebar"

      expect(rendered).to match '<span class="value">Casa Admin</span>'
    end

    it "renders only menu items visible by admins" do
      sign_in user

      render partial: "layouts/sidebar"

      expect(rendered).to have_link("Volunteers", href: "/volunteers")
      expect(rendered).to have_link("Cases", href: "/casa_cases")
      expect(rendered).to have_link("Case Contacts", href: "/case_contacts")
      expect(rendered).to have_link("Supervisors", href: "/supervisors")
      expect(rendered).to have_link("Admins", href: "/casa_admins")
    end
  end
end

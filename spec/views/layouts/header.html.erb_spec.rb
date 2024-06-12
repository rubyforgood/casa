require "rails_helper"

module PretenderContext
  def true_user
  end
end

RSpec.describe "layout/header", type: :view do
  before do
    view.class.include PretenderContext

    enable_pundit(view, user)
    allow(view).to receive(:true_user).and_return(user)
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:current_role).and_return(user.role)

    casa_org = build_stubbed :casa_org
    allow(view).to receive(:current_organization).and_return(casa_org)
  end

  context "when logged in as a casa admin" do
    let(:user) { build_stubbed :casa_admin }

    it "renders user information", :aggregate_failures do
      sign_in user

      render partial: "layouts/header"

      expect(rendered).to match "<strong>Role: Casa Admin</strong>"
      expect(rendered).to match CGI.escapeHTML user.display_name
      expect(rendered).to match CGI.escapeHTML user.email
    end

    it "renders help issue link on the header" do
      render partial: "layouts/header"
      expect(rendered).to have_link("Help", href: "https://thunder-flower-8c2.notion.site/Casa-Volunteer-Tracking-App-HelpSite-3b95705e80c742ffa729ccce7beeabfa")
    end
  end

  context "when logged in as a supervisor" do
    let(:user) { build_stubbed :supervisor }

    it "renders user information", :aggregate_failures do
      sign_in user

      render partial: "layouts/header"

      expect(rendered).to match "<strong>Role: Supervisor</strong>"
      expect(rendered).to match CGI.escapeHTML user.display_name
      expect(rendered).to match CGI.escapeHTML user.email
    end

    it "renders help issue link on the header" do
      render partial: "layouts/header"
      expect(rendered).to have_link("Help", href: "https://thunder-flower-8c2.notion.site/Casa-Volunteer-Tracking-App-HelpSite-3b95705e80c742ffa729ccce7beeabfa")
    end
  end

  context "when logged in as a volunteer" do
    let(:user) { build_stubbed :volunteer }

    it "renders user information", :aggregate_failures do
      sign_in user

      render partial: "layouts/header"

      expect(rendered).to match "<strong>Role: Volunteer</strong>"
      expect(rendered).to match CGI.escapeHTML user.display_name
      expect(rendered).to match CGI.escapeHTML user.email
    end

    it "does not render unauthorized links" do
      sign_in user

      render partial: "layouts/header"

      expect(rendered).to_not have_link("Edit Organization")
    end

    it "renders help issue link on the header" do
      render partial: "layouts/header"
      expect(rendered).to have_link("Help", href: "https://thunder-flower-8c2.notion.site/Casa-Volunteer-Tracking-App-HelpSite-Volunteers-c24d9d2ef8b249bbbda8192191365039?pvs=4")
    end
  end

  context "notifications" do
    let(:user) { build_stubbed :casa_admin }

    it "displays unread notification count if the user has unread notifications" do
      sign_in user
      build(:notification)
      allow(user).to receive_message_chain(:notifications, :unread).and_return([:notification])

      render partial: "layouts/header"

      expect(rendered).to match "<span>1</span>"
    end

    it "does not display unread notification count if the user has no unread notifications" do
      sign_in user
      allow(user).to receive_message_chain(:notifications, :unread).and_return([])

      render partial: "layouts/header"

      expect(rendered).not_to match "<span>0</span>"
    end
  end

  context "impersonation" do
    let(:user) { build_stubbed :volunteer }
    let(:true_user) { build_stubbed :casa_admin }

    it "renders correct role name when impersonating a volunteer" do
      allow(view).to receive(:true_user).and_return(true_user)

      render partial: "layouts/header"

      expect(rendered).to match "<strong>Role: Volunteer</strong>"
    end

    it "renders a stop impersonating link when impersonating" do
      allow(view).to receive(:true_user).and_return(true_user)

      render partial: "layouts/header"

      expect(rendered).to have_link(href: "/volunteers/stop_impersonating")
    end
  end
end

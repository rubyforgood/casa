require "rails_helper"

module PretenderContext
  def true_user
  end
end

RSpec.describe "layout/sidebar", type: :view do
  before do
    view.class.include PretenderContext

    enable_pundit(view, user)
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:true_user).and_return(user)
    allow(view).to receive(:user_signed_in?).and_return(true)
    allow(view).to receive(:current_role).and_return(user.role)
    allow(view).to receive(:current_organization).and_return(user.casa_org)

    assign :casa_org, user.casa_org
  end

  context "when no organization logo is set" do
    let(:user) { build_stubbed :volunteer }

    it "displays default logo" do
      sign_in user

      render partial: "layouts/sidebar"

      expect(rendered).to have_xpath("//img[contains(@src,'default-logo') and @alt='CASA Logo']")
    end
  end

  context "when logged in as a supervisor" do
    let(:user) do
      build_stubbed :supervisor, display_name: "Supervisor's name",
        email: "supervisor&email@test.com"
    end

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
      expect(rendered).to_not have_link("Case Contacts", href: "/case_contacts")
      expect(rendered).to_not have_link("Admins", href: "/casa_admins")
      expect(rendered).to have_link("Generate Court Reports", href: "/case_court_reports")
      expect(rendered).to have_link("Export Data", href: "/reports")
      expect(rendered).to_not have_link("Emancipation Checklist", href: "/emancipation_checklists/0")
    end

    it "renders display name and email" do
      sign_in user

      render partial: "layouts/sidebar"

      expect(rendered).to match CGI.escapeHTML user.display_name
      expect(rendered).to match CGI.escapeHTML user.email
    end
  end

  context "when logged in as a volunteer" do
    let(:organization) { build(:casa_org) }

    let(:user) do
      create(
        :volunteer,
        casa_org: organization,
        display_name: "Volunteer's name%"
      )
    end

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
      expect(rendered).to have_link("Generate Court Report", href: "/case_court_reports")
      expect(rendered).to_not have_link("Export Data", href: "/reports")
      expect(rendered).to_not have_link("Volunteers", href: "/volunteers")
      expect(rendered).to_not have_link("Supervisors", href: "/supervisors")
      expect(rendered).to_not have_link("Admins", href: "/casa_admins")
    end

    it "renders display name and email" do
      sign_in user

      render partial: "layouts/sidebar"

      expect(rendered).to match CGI.escapeHTML user.display_name
      expect(rendered).to match CGI.escapeHTML user.email
    end

    context "when the volunteer does not have a transitioning case" do
      it "does not render emancipation checklist(s)" do
        sign_in user

        # 0 Cases
        render partial: "layouts/sidebar"
        expect(rendered).to_not have_link("Emancipation Checklist", href: "/emancipation_checklists")

        # 1 Non transitioning case
        casa_case = build_stubbed(:casa_case, :pre_transition, casa_org: organization)
        build_stubbed(:case_assignment, volunteer: user, casa_case: casa_case)

        render partial: "layouts/sidebar"
        expect(rendered).to_not have_link("Emancipation Checklist", href: "/emancipation_checklists")
      end
    end

    context "when the user has only inactive or unassigned transiting cases" do
      it "does not render emancipation checklist(s)" do
        sign_in user

        inactive_case = build_stubbed(:casa_case, casa_org: organization, active: false)
        build_stubbed(:case_assignment, volunteer: user, casa_case: inactive_case)

        unassigned_case = build_stubbed(:casa_case, casa_org: organization)
        build_stubbed(:case_assignment, volunteer: user, casa_case: unassigned_case, active: false)

        render partial: "layouts/sidebar"
        expect(rendered).to_not have_link("Emancipation Checklist", href: "/emancipation_checklists")
      end
    end

    context "when the volunteer has a transitioning case" do
      let(:casa_case) { create(:casa_case, casa_org: organization) }
      let!(:case_assignment) { create(:case_assignment, volunteer: user, casa_case: casa_case) }

      it "renders emancipation checklist(s)" do
        sign_in user

        render partial: "layouts/sidebar"
        expect(rendered).to have_link("Emancipation Checklist", href: "/emancipation_checklists")
      end
    end
  end

  context "when logged in as a casa admin" do
    let(:user) { build_stubbed :casa_admin, display_name: "Superviso's another n&ame" }

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
      expect(rendered).to_not have_link("Case Contacts", href: "/case_contacts")
      expect(rendered).to have_link("Supervisors", href: "/supervisors")
      expect(rendered).to have_link("Admins", href: "/casa_admins")
      expect(rendered).to have_link("System Imports", href: "/imports")
      expect(rendered).to have_link("Edit Organization", href: "/casa_org/#{user.casa_org.id}/edit")
      expect(rendered).to have_link("Generate Court Reports", href: "/case_court_reports")
      expect(rendered).to have_link("Export Data", href: "/reports")
      expect(rendered).to_not have_link("Emancipation Checklist", href: "/emancipation_checklists")
    end
  end

  context "notifications" do
    let(:user) { build_stubbed(:volunteer) }

    it "displays badge when user has notifications" do
      sign_in user
      build_stubbed(:notification)
      allow(user).to receive_message_chain(:notifications, :unread).and_return([:notification])

      render partial: "layouts/sidebar"

      expect(rendered).to have_css("span.badge")
    end

    it "displays no badge when user has no unread notifications" do
      sign_in user
      allow(user).to receive_message_chain(:notifications, :unread).and_return([])

      render partial: "layouts/sidebar"

      expect(rendered).not_to have_css("span.badge")
    end
  end

  context "impersonation" do
    let(:user) { build_stubbed :volunteer }
    let(:true_user) { build_stubbed :casa_admin }

    it "renders a stop impersonating link when impersonating" do
      allow(view).to receive(:true_user).and_return(true_user)

      render partial: "layouts/sidebar"

      expect(rendered).to have_link(href: "/volunteers/stop_impersonating")
    end

    it "renders correct Role name when impersonating a volunteer" do
      allow(view).to receive(:true_user).and_return(true_user)

      render partial: "layouts/sidebar"

      expect(rendered).to match '<span class="value">Volunteer</span>'
    end
  end
end

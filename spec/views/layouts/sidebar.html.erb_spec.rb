require "rails_helper"

RSpec.describe "layout/sidebar", :disable_bullet, type: :view do
  before do
    enable_pundit(view, user)
    allow(view).to receive(:current_user).and_return(user)
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
      expect(rendered).to_not have_link("Case Contacts", href: "/case_contacts")
      expect(rendered).to have_link("Report a site issue", href: "https://rubyforgood.typeform.com/to/iXY4BubB")
      expect(rendered).to_not have_link("Admins", href: "/casa_admins")
      expect(rendered).to_not have_link("Generate Court Reports", href: "/case_court_reports")
      expect(rendered).to_not have_link("Emancipation Checklist", href: "/emancipation_checklists/0")
    end
  end

  context "when logged in as a volunteer" do
    let(:organization) { create(:casa_org) }
    let(:user) { create(:volunteer, casa_org: organization) }

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
      expect(rendered).to have_link("Report a site issue", href: "https://rubyforgood.typeform.com/to/iXY4BubB")
      expect(rendered).to_not have_link("Volunteers", href: "/volunteers")
      expect(rendered).to_not have_link("Supervisors", href: "/supervisors")
      expect(rendered).to_not have_link("Admins", href: "/casa_admins")
    end

    context "when the volunteer does not have a transitioning case" do
      it "does not render emancipation checklist(s)" do
        sign_in user

        # 0 Cases
        render partial: "layouts/sidebar"
        expect(rendered).to_not have_link("Emancipation Checklist", href: "/emancipation_checklists")

        # 1 Non transitioning case
        casa_case = create(:casa_case, casa_org: organization, transition_aged_youth: false)
        create(:case_assignment, volunteer: user, casa_case: casa_case)

        render partial: "layouts/sidebar"
        expect(rendered).to_not have_link("Emancipation Checklist", href: "/emancipation_checklists")
      end
    end

    context "when the user has only inactive or unassigned transiting cases" do
      it "does not render emancipation checklist(s)" do
        sign_in user

        inactive_case = create(:casa_case, casa_org: organization, transition_aged_youth: true, active: false)
        create(:case_assignment, volunteer: user, casa_case: inactive_case)

        unassigned_case = create(:casa_case, casa_org: organization, transition_aged_youth: true)
        create(:case_assignment, volunteer: user, casa_case: unassigned_case, active: false)

        render partial: "layouts/sidebar"
        expect(rendered).to_not have_link("Emancipation Checklist", href: "/emancipation_checklists")
      end
    end

    context "when the volunteer has a transitioning case" do
      let(:casa_case) { create(:casa_case, casa_org: organization, transition_aged_youth: true) }
      let!(:case_assignment) { create(:case_assignment, volunteer: user, casa_case: casa_case) }

      it "renders emancipation checklist(s)" do
        sign_in user

        render partial: "layouts/sidebar"
        expect(rendered).to have_link("Emancipation Checklist", href: "/emancipation_checklists")
      end
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
      expect(rendered).to_not have_link("Case Contacts", href: "/case_contacts")
      expect(rendered).to have_link("Supervisors", href: "/supervisors")
      expect(rendered).to have_link("Admins", href: "/casa_admins")
      expect(rendered).to have_link("Report a site issue", href: "https://rubyforgood.typeform.com/to/iXY4BubB")
      expect(rendered).to_not have_link("Generate Court Reports", href: "/case_court_reports")
      expect(rendered).to_not have_link("Emancipation Checklist", href: "/emancipation_checklists")
    end
  end

  context "notifications" do
    let(:user) { build_stubbed :volunteer }

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
end

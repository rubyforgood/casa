require "rails_helper"

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

  shared_examples_for "properly rendering custom org links" do
    let(:active_link_text) { "Example Link" }
    let(:active_link_url) { "https://www.example.com" }
    let(:inactive_link_text) { "Hidden Link" }
    let(:inactive_link_url) { "https://www.nothing.com" }
    let(:other_org_link_text) { "That Other Link" }
    let(:other_org_link_url) { "https://www.elsewhere.com" }

    before do
      create :custom_org_link, casa_org: user.casa_org, text: active_link_text, url: active_link_url, active: true
      create :custom_org_link, casa_org: user.casa_org, text: inactive_link_text, url: inactive_link_url, active: false
      create :custom_org_link, text: other_org_link_text, url: other_org_link_url, active: true
    end

    it "renders active custom links for the user's org" do
      render partial: "layouts/sidebar"
      expect(rendered).to have_link(active_link_text, href: active_link_url)
    end

    it "does not render inactive custom links for the user's org" do
      render partial: "layouts/sidebar"
      expect(rendered).not_to have_link(inactive_link_text, href: inactive_link_url)
    end

    it "does not render custom links for other orgs" do
      render partial: "layouts/sidebar"
      expect(rendered).not_to have_link(other_org_link_text, href: other_org_link_url)
    end
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

    it "renders only menu items visible by supervisors" do
      sign_in user

      render partial: "layouts/sidebar"

      expect(rendered).to have_link("Supervisors", href: "/supervisors")
      expect(rendered).to have_link("Volunteers", href: "/volunteers")
      expect(rendered).to have_link("Cases", href: "/casa_cases")
      expect(rendered).not_to have_link("Case Contacts", href: "/case_contacts")
      expect(rendered).not_to have_link("Admins", href: "/casa_admins")
      expect(rendered).to have_link("Generate Court Reports", href: "/case_court_reports")
      expect(rendered).to have_link("Export Data", href: "/reports")
      expect(rendered).not_to have_link("Emancipation Checklist", href: "/emancipation_checklists/0")
      expect(rendered).not_to have_link("System Settings", href: "/settings")
      expect(rendered).to have_link("Other Duties", href: "/other_duties")
      expect(rendered).not_to have_link("Organization Details", href: "/casa_org/#{user.casa_org.id}/edit#organization-details")
      expect(rendered).not_to have_link("Contact Types", href: "/casa_org/#{user.casa_org.id}/edit#contact-types")
      expect(rendered).not_to have_link("Court Details", href: "/casa_org/#{user.casa_org.id}/edit#court-details")
      expect(rendered).not_to have_link("Learning Hours", href: "/casa_org/#{user.casa_org.id}/edit#learning-hours")
      expect(rendered).not_to have_link("Case Contact Topics", href: "/casa_org/#{user.casa_org.id}/edit#case-contact-topics")
    end

    it_behaves_like "properly rendering custom org links"

    context "when casa_org other_duties_enabled is true" do
      before do
        user.casa_org.other_duties_enabled = true
        sign_in user
        render partial: "layouts/sidebar"
      end

      it "renders Other Duties" do
        expect(rendered).to have_link("Other Duties", href: "/other_duties")
      end
    end

    context "when casa_org other_duties_enabled is false" do
      before do
        user.casa_org.other_duties_enabled = false

        sign_in user
        render partial: "layouts/sidebar"
      end

      it "does not renders Other Duties" do
        expect(rendered).not_to have_link("Other Duties", href: "/other_duties")
      end
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

    it "renders only menu items visible by volunteers" do
      sign_in user

      render partial: "layouts/sidebar"

      expect(rendered).to have_link("All", href: "/casa_cases")
      expect(rendered).to have_link("All", href: "/case_contacts")
      expect(rendered).to have_link("Generate Court Report", href: "/case_court_reports")
      expect(rendered).not_to have_link("Export Data", href: "/reports")
      expect(rendered).not_to have_link("Volunteers", href: "/volunteers")
      expect(rendered).not_to have_link("Supervisors", href: "/supervisors")
      expect(rendered).not_to have_link("Admins", href: "/casa_admins")
      expect(rendered).not_to have_link("System Settings", href: "/settings")
      expect(rendered).to have_link("Other Duties", href: "/other_duties")
      expect(rendered).not_to have_link("Organization Details", href: "/casa_org/#{user.casa_org.id}/edit#organization-details")
      expect(rendered).not_to have_link("Contact Types", href: "/casa_org/#{user.casa_org.id}/edit#contact-types")
      expect(rendered).not_to have_link("Court Details", href: "/casa_org/#{user.casa_org.id}/edit#court-details")
      expect(rendered).not_to have_link("Learning Hours", href: "/casa_org/#{user.casa_org.id}/edit#learning-hours")
      expect(rendered).not_to have_link("Case Contact Topics", href: "/casa_org/#{user.casa_org.id}/edit#case-contact-topics")
    end

    it_behaves_like "properly rendering custom org links"

    context "when casa_org other_duties_enabled is true" do
      before do
        user.casa_org.other_duties_enabled = true
        sign_in user
        render partial: "layouts/sidebar"
      end

      it "renders Other Duties" do
        expect(rendered).to have_link("Other Duties", href: "/other_duties")
      end
    end

    context "when casa_org other_duties_enabled is false" do
      before do
        user.casa_org.other_duties_enabled = false

        sign_in user
        render partial: "layouts/sidebar"
      end

      it "does not renders Other Duties" do
        expect(rendered).not_to have_link("Other Duties", href: "/other_duties")
      end
    end

    context "when the volunteer does not have a transitioning case" do
      it "does not render emancipation checklist(s)" do
        sign_in user

        # 0 Cases
        render partial: "layouts/sidebar"
        expect(rendered).not_to have_link("Emancipation Checklist", href: "/emancipation_checklists")

        # 1 Non transitioning case
        casa_case = build_stubbed(:casa_case, :pre_transition, casa_org: organization)
        build_stubbed(:case_assignment, volunteer: user, casa_case: casa_case)

        render partial: "layouts/sidebar"
        expect(rendered).not_to have_link("Emancipation Checklist", href: "/emancipation_checklists")
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
        expect(rendered).not_to have_link("Emancipation Checklist", href: "/emancipation_checklists")
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

    it "renders only menu items visible by admins" do
      sign_in user

      render partial: "layouts/sidebar"

      expect(rendered).to have_link("Volunteers", href: "/volunteers")
      expect(rendered).to have_link("Cases", href: "/casa_cases")
      expect(rendered).not_to have_link("Case Contacts", href: "/case_contacts")
      expect(rendered).to have_link("Supervisors", href: "/supervisors")
      expect(rendered).to have_link("Admins", href: "/casa_admins")
      expect(rendered).to have_link("System Imports", href: "/imports")
      expect(rendered).to have_link("Generate Court Reports", href: "/case_court_reports")
      expect(rendered).to have_link("Export Data", href: "/reports")
      expect(rendered).not_to have_link("Emancipation Checklist", href: "/emancipation_checklists")
      expect(rendered).to have_link("Other Duties", href: "/other_duties")
      expect(rendered).to have_link("Organization Details", href: "/casa_org/#{user.casa_org.id}/edit#organization-details")
      expect(rendered).to have_link("Contact Types", href: "/casa_org/#{user.casa_org.id}/edit#contact-types")
      expect(rendered).to have_link("Court Details", href: "/casa_org/#{user.casa_org.id}/edit#court-details")
      expect(rendered).to have_link("Learning Hours", href: "/casa_org/#{user.casa_org.id}/edit#learning-hours")
      expect(rendered).to have_link("Case Contact Topics", href: "/casa_org/#{user.casa_org.id}/edit#case-contact-topics")
    end

    it_behaves_like "properly rendering custom org links"

    context "when casa_org other_duties_enabled is true" do
      before do
        user.casa_org.other_duties_enabled = true
        sign_in user
        render partial: "layouts/sidebar"
      end

      it "renders Other Duties" do
        expect(rendered).to have_link("Other Duties", href: "/other_duties")
      end
    end

    context "when casa_org other_duties_enabled is false" do
      before do
        user.casa_org.other_duties_enabled = false

        sign_in user
        render partial: "layouts/sidebar"
      end

      it "does not renders Other Duties" do
        expect(rendered).not_to have_link("Other Duties", href: "/other_duties")
      end
    end
  end
end

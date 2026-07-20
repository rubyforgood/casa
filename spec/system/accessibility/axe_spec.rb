require "rails_helper"
require "axe-rspec"

# Automated accessibility (axe-core) pass over the migrated casa_app / casa_auth
# pages. Each example loads a page in a real (headless-chrome) browser and
# asserts there are no axe violations.
RSpec.describe "Accessibility (axe)", type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let!(:casa_case) { create(:casa_case, casa_org: organization) }

  def expect_axe_clean(path)
    visit path
    expect(page).to be_axe_clean
  end

  context "signed in as an admin" do
    before { sign_in admin }

    it("dashboard", :js) { expect_axe_clean authenticated_user_root_path }
    it("cases index", :js) { expect_axe_clean casa_cases_path }
    it("case show", :js) { expect_axe_clean casa_case_path(casa_case) }
    it("case edit", :js) { expect_axe_clean edit_casa_case_path(casa_case) }
    it("case contacts index", :js) { expect_axe_clean case_contacts_path }
    it("volunteers index", :js) { expect_axe_clean volunteers_path }
    it("supervisors index", :js) { expect_axe_clean supervisors_path }
    it("reports index", :js) { expect_axe_clean reports_path }
    it("learning hours index", :js) { expect_axe_clean learning_hours_path }
    it("reimbursements index", :js) { expect_axe_clean reimbursements_path }
    it("admins index", :js) { expect_axe_clean casa_admins_path }
    it("org settings", :js) { expect_axe_clean edit_casa_org_path(organization) }
  end

  context "signed out" do
    it("sign in", :js) { expect_axe_clean new_user_session_path }
  end
end

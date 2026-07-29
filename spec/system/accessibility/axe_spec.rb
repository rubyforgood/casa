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

  context "case contact form (details step)" do
    let(:organization) { create(:casa_org, :all_reimbursements_enabled) }
    let(:volunteer) { create(:volunteer, :with_single_case, casa_org: organization) }
    let!(:contact_topic) { create(:contact_topic, casa_org: organization) }
    let(:contact_type) { create(:contact_type, casa_org: organization) }
    let(:case_contact) do
      create(:case_contact, :wants_reimbursement, creator: volunteer,
        casa_case: volunteer.casa_cases.first, contact_types: [contact_type])
    end
    let!(:expense) { create(:additional_expense, case_contact: case_contact) }

    before do
      allow(Flipper).to receive(:enabled?).and_call_original
      allow(Flipper).to receive(:enabled?).with(:show_additional_expenses).and_return(true)
      sign_in volunteer
    end

    it("details / notes / reimbursement + expenses", :js) do
      visit case_contact_form_path(case_contact_id: case_contact.id, id: :details)
      check "Request travel or other reimbursement"
      expect(page).to have_field("case_contact_volunteer_address_line_1") # reimbursement revealed
      expect(page).to be_axe_clean
    end
  end

  # Pages a whole-app axe sweep flagged, now fixed: heading-order (an <h6> subtitle under the
  # page <h1>, and an <h6> nested in a <dt>), link-in-text-block, aria-input-field-name +
  # scrollable-region-focusable (Trix), label (the import file inputs) and color-contrast
  # (emerald-600 as text). Each example seeds the rows its page needs -- axe only sees the
  # rendered DOM, so an empty collection audits clean and hides the defect.
  context "pages fixed by the whole-app WCAG sweep" do
    let(:volunteer) { create(:volunteer, :with_single_case, casa_org: organization) }
    let!(:court_date) { create(:court_date, casa_case: casa_case) }
    let!(:placement_type) { create(:placement_type, casa_org: organization) }
    let!(:placement) { create(:placement, casa_case: casa_case, creator: admin, placement_type: placement_type) }
    let!(:banner) { create(:banner, casa_org: organization, user: admin) }
    let!(:mileage_rate) { create(:mileage_rate, casa_org: organization) }
    let!(:active_topic) { create(:contact_topic, casa_org: organization, active: true) }
    let!(:inactive_topic) { create(:contact_topic, casa_org: organization, active: false) }
    let!(:draft) { create(:case_contact, :started_status, creator: volunteer, draft_case_ids: [casa_case.id]) }
    # A month-over-month delta has to be non-zero for the analytics stat cards to render the
    # coloured "+N vs last month" line at all.
    let!(:contacts) { create_list(:case_contact, 3, creator: volunteer, casa_case: casa_case) }

    before { sign_in admin }

    it("court date new", :js) { expect_axe_clean new_casa_case_court_date_path(casa_case) }
    it("court date show", :js) { expect_axe_clean casa_case_court_date_path(casa_case, court_date) }
    it("court date edit", :js) { expect_axe_clean edit_casa_case_court_date_path(casa_case, court_date) }
    it("bulk court date new", :js) { expect_axe_clean new_bulk_court_date_path }
    it("placements index", :js) { expect_axe_clean casa_case_placements_path(casa_case) }
    it("placement new", :js) { expect_axe_clean new_casa_case_placement_path(casa_case) }
    it("placement edit", :js) { expect_axe_clean edit_casa_case_placement_path(casa_case, placement) }
    it("case contacts drafts", :js) { expect_axe_clean case_contacts_drafts_path }
    it("banner new (trix)", :js) { expect_axe_clean new_banner_path }
    it("banner edit (trix)", :js) { expect_axe_clean edit_banner_path(banner) }
    it("mileage rate edit", :js) { expect_axe_clean edit_mileage_rate_path(mileage_rate) }
    it("imports", :js) { expect_axe_clean imports_path }
    it("analytics", :js) { expect_axe_clean analytics_path }
    it("org settings with contact topics", :js) { expect_axe_clean edit_casa_org_path(organization) }
  end

  context "emancipation checklist" do
    let(:volunteer) { create(:volunteer, :with_single_case, casa_org: organization) }
    let!(:category) { create(:emancipation_category) }
    let!(:option) { create(:emancipation_option, emancipation_category: category) }

    before { sign_in volunteer }

    it("emancipation", :js) { expect_axe_clean casa_case_emancipation_path(volunteer.casa_cases.first) }
  end

  context "signed out" do
    it("sign in", :js) { expect_axe_clean new_user_session_path }
  end
end

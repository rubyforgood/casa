require "rails_helper"

RSpec.describe "casa_cases/edit volunteer assignment card", type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let!(:casa_case) { create(:casa_case, casa_org: organization) }
  let!(:active_vol) { create(:volunteer, casa_org: organization, display_name: "Active Volunteer") }
  let!(:past_vol) { create(:volunteer, casa_org: organization, display_name: "Past Volunteer") }
  let!(:active_assignment) { create(:case_assignment, casa_case: casa_case, volunteer: active_vol, active: true) }
  let!(:past_assignment) { create(:case_assignment, casa_case: casa_case, volunteer: past_vol, active: false) }

  before { sign_in admin }

  it "shows Unassigned only when there is one, never a label with nothing after it" do
    visit edit_casa_case_path(casa_case)

    active_row = find("#volunteer-assignment li", text: "Active Volunteer")
    past_row = find("#volunteer-assignment li", text: "Past Volunteer")

    # An active assignment has no unassigned date, so the pair is omitted rather than rendered as a
    # label and a hanging colon with an empty value.
    expect(active_row).to have_text("Assigned:")
    expect(active_row).to have_no_text("Unassigned:")
    expect(past_row).to have_text("Unassigned:")

    # No fact in either row is a label with an empty value.
    [active_row, past_row].each do |row|
      expect(row.all("dd").map { |dd| dd.text.strip }).to all(be_present)
    end
  end

  it "styles the reimbursement checkbox as a control, not as another fact label" do
    visit edit_casa_case_path(casa_case)
    row = find("#volunteer-assignment li", text: "Active Volunteer")

    # design.md Label token; at the fact-label size/colour it was indistinguishable from the
    # "Assigned:" metadata beside it, which is what made the card hard to parse.
    label = row.find("label", text: "Enable reimbursement")
    expect(label[:class]).to include("text-sm", "font-medium", "text-slate-700")
  end
end

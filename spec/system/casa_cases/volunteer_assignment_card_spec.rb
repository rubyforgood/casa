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

  it "renders the email and the assignment facts at the body size, not the 12px chrome size", :js do
    visit edit_casa_case_path(casa_case)
    expect(page).to have_css("#volunteer-assignment li")

    sizes = page.evaluate_script(<<~JS)
      (function () {
        const row = [...document.querySelectorAll('#volunteer-assignment li')]
          .find(li => li.textContent.includes('Active Volunteer'))
        const px = el => el ? parseFloat(getComputedStyle(el).fontSize) : null
        return {
          email: px(row.querySelector("[data-test='volunteer-email']")),
          label: px(row.querySelector('dt')),
          value: px(row.querySelector('dd'))
        }
      })()
    JS

    # An email and an assignment date are content the user reads and transcribes. They had been shrunk
    # to 12px to cut the number of type sizes in the card, which is what made it hard to read; 12px is
    # for the status pill and for a stacked label sitting above its value.
    expect(sizes.values).to all(eq(14))
  end

  it "offers the volunteer picker as a searchable typeahead", :js do
    unassigned = create(:volunteer, casa_org: organization, display_name: "Zoe Zeta")
    visit edit_casa_case_path(casa_case)

    # A chapter has hundreds of volunteers, so the picker searches rather than making the user scroll a
    # native dropdown.
    within "#volunteer-assignment" do
      expect(page).to have_css(".ts-control")
      find(".ts-control input").set("Zoe")
    end
    # Not inside the card: the menu is rendered on <body> (dropdownParent) because the card clips.
    find(".ts-dropdown .option", text: "Zoe Zeta").click

    expect(find("#case_assignment_casa_case_id", visible: :all).value).to eq(unassigned.id.to_s)
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

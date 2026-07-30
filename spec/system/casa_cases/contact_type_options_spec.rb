require "rails_helper"

RSpec.describe "casa_cases/edit contact type options", :js, type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }
  let(:volunteer) { create(:volunteer, casa_org: organization) }
  let!(:ctg) { create(:contact_type_group, casa_org: organization, name: "Group A") }
  let!(:used) { create(:contact_type, contact_type_group: ctg, name: "Used type") }
  let!(:unused) { create(:contact_type, contact_type_group: ctg, name: "Unused type") }
  let!(:contact) do
    c = create(:case_contact, casa_case: casa_case, creator: volunteer, occurred_at: 3.days.ago)
    c.contact_types = [used]
    c
  end

  it "shows recency for a used type and nothing for an unused one" do
    sign_in admin
    visit edit_casa_case_path(casa_case)
    expect(page).to have_css("#contact-type-id-selector")

    find("#contact-type-id-selector .ts-control").click

    used_option = find(".ts-dropdown .option", text: "Used type")
    expect(used_option).to have_text("Last logged 3 days ago")

    # A type with no contacts logged shows no subtext -- not a bare "never" beside every option. The
    # subtext must also not be nil: it goes through TomSelect's escape(), which renders nil as "null".
    unused_subtext = page.evaluate_script(<<~JS)
      (function() {
        const opt = [...document.querySelectorAll('.ts-dropdown .option')]
          .find(o => o.textContent.trim().startsWith('Unused type'))
        const sub = opt && opt.querySelector('small')
        return sub ? sub.textContent.trim() : 'NO SUBTEXT ELEMENT'
      })()
    JS
    expect(unused_subtext).to eq ""
    expect(page).to have_no_text("never")
    expect(page).to have_no_text("null")
  end
end

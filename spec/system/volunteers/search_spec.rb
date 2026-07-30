require "rails_helper"

RSpec.describe "volunteers/index search", :js, type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let!(:a) { create(:volunteer, casa_org: organization, display_name: "Aaron Ackerman") }
  let!(:b) { create(:volunteer, casa_org: organization, display_name: "Beatrice Bowman") }

  # Names only, and never the full row text: the email column is a FactoryBot sequence, so its value
  # depends on how many records earlier examples created (it shifted from email2@ to email411@ in a
  # batch run).
  def names
    page.all("#volunteers tbody tr").map { |row| row.all("td")[1].text }
  end

  it "searches as you type, keeps focus and caret, and clears properly" do
    sign_in admin
    visit volunteers_path
    expect(page).to have_text("Aaron Ackerman")

    find("#search").send_keys("Beat")
    # no blur, no Enter -- the debounce should do it
    expect(page).to have_no_text("Aaron Ackerman")
    expect(names).to eq ["Beatrice Bowman"]
    expect(page.current_url).to include("search=Beat")

    # Turbo Drive is off app-wide, so the submit is a real page load: without the controller parking
    # the caret, focus lands on <body> and the next keystroke goes nowhere.
    focus = page.evaluate_script(<<~JS)
      (function() {
        const f = document.querySelector('#search')
        return { focused: document.activeElement === f, caret: f.selectionStart, value: f.value }
      })()
    JS
    expect(focus["focused"]).to be true
    expect(focus["caret"]).to eq 4
    expect(focus["value"]).to eq "Beat"

    # typing more should refine without losing position
    find("#search").send_keys("rice")
    expect(page).to have_css("#search")
    expect(find("#search").value).to eq "Beatrice"

    find("a[aria-label='Clear search']").click
    expect(page).to have_text("Aaron Ackerman")
    expect(find("#search").value).to eq ""
    expect(names).to contain_exactly("Aaron Ackerman", "Beatrice Bowman")
  end
end

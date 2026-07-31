require "rails_helper"

RSpec.describe "announcement banner preview", type: :system do
  # A design preview is only useful if it renders what ships. `shipped` renders the real partial, and
  # both pages are checked here because Tailwind's @source list covers app/ and NOT spec/ -- a utility
  # used only in a preview template silently does not exist in the built CSS, so the preview scaffolding
  # is inline styles and a regression here would mean the page had started lying.
  it "renders the shipped bar with its accent band", :js do
    visit "/rails/view_components/announcement_banner/shipped"

    expect(page).to have_css("[class*='border-l-amber-600']", minimum: 2)
    expect(page).to have_css("i.bi-megaphone", visible: :all)
  end

  it "renders every lead variant at both widths", :js do
    visit "/rails/view_components/announcement_banner/lead_variants"

    widths = page.evaluate_script(<<~JS)
      [...document.querySelectorAll("[class*='border-l-amber-600']")]
        .map(el => Math.round(el.getBoundingClientRect().width))
    JS

    # 8 rows x 2 widths, and the narrow ones really are ~390px rather than full-bleed.
    expect(widths.size).to eq(16)
    expect(widths.count { |w| w.between?(380, 392) }).to eq(8)
  end
end

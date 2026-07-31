require "rails_helper"

RSpec.describe "org announcement banner", type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let!(:banner) do
    create(:banner, casa_org: organization, user: admin, active: true,
      content: "Quarterly court reports are due at month end.")
  end

  before { sign_in admin }

  # A plain leading glyph. It briefly wore a filled amber-700 tile to "ground" it; that read as a
  # shout and pushed the bar from 44px to 57px, so the tile is gone and the bar is back to its
  # height. Every message-bar pattern in the wild (Polaris, Material, Carbon, Primer) leads with a
  # bare tone-coloured glyph and lets the tint plus border carry the severity.
  it "leads with a plain glyph, no tile" do
    visit authenticated_user_root_path

    bar = find("[data-controller='dismiss']")
    expect(bar).to have_css("i.bi-megaphone", visible: :all)
    expect(bar).to have_no_css("span[aria-hidden='true']")
  end

  it "keeps the icon on the first line and the bar compact", :js do
    visit authenticated_user_root_path

    m = page.evaluate_script(<<~JS)
      (function () {
        const bar = document.querySelector("[data-controller='dismiss']")
        const icon = bar.querySelector('i').getBoundingClientRect()
        const body = bar.querySelector('div.min-w-0')
        const range = document.createRange()
        range.selectNodeContents(body)
        // Line rects only: the first rect getClientRects returns is the block itself.
        const lines = [...range.getClientRects()].filter(r => r.height < 30)
        return {
          bar_height: bar.getBoundingClientRect().height,
          icon_mid: (icon.top + icon.bottom) / 2,
          line_mid: (lines[0].top + lines[0].bottom) / 2
        }
      })()
    JS

    # The icon's BOX sits 2px below the line box on purpose: aligned boxes put the glyph's ink 2px
    # above the text's x-height band (measured 85.5 vs 88.0), which reads as floating. With mt-0.5 the
    # ink lands at 87.5 against 88.0. Align ink, not boxes.
    expect(m["icon_mid"] - m["line_mid"]).to be_within(1).of(2)
    # Back to the pre-tile height, measured on both: 47px. The tile made it 57px.
    expect(m["bar_height"]).to be < 50
  end
end

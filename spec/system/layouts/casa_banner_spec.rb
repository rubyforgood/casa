require "rails_helper"

RSpec.describe "org announcement banner", type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let!(:banner) do
    create(:banner, casa_org: organization, user: admin, active: true,
      content: "Quarterly court reports are due at month end.")
  end

  before { sign_in admin }

  it "grounds the icon in a tile instead of floating a bare glyph" do
    visit authenticated_user_root_path

    tile = find("[data-controller='dismiss'] span[aria-hidden='true']")
    # design.md's icon-tile pattern; filled rather than the usual soft bg-{hue}-50, which is invisible
    # on this amber-50 bar (amber-100 measures 1.07:1 against it).
    expect(tile[:class]).to include("rounded-xl", "bg-amber-700", "text-white", "h-8", "w-8")
    expect(tile).to have_css("i.bi-megaphone", visible: :all)
  end

  it "centres the tile, the text and Dismiss on the same line", :js do
    visit authenticated_user_root_path

    centres = page.evaluate_script(<<~JS)
      (function () {
        const bar = document.querySelector("[data-controller='dismiss']")
        const mid = (el) => { const b = el.getBoundingClientRect(); return (b.top + b.bottom) / 2 }
        const body = bar.querySelector('div.min-w-0')
        const range = document.createRange()
        range.selectNodeContents(body)
        // Line rects only: the first rect getClientRects returns is the block itself.
        const lines = [...range.getClientRects()].filter(r => r.height < 30)
        return {
          tile: mid(bar.querySelector('span[aria-hidden]')),
          firstLine: (lines[0].top + lines[0].bottom) / 2,
          dismiss: mid(bar.querySelector('button'))
        }
      })()
    JS

    # The text is nudged to the tile's centre line rather than the tile up into the bar's padding.
    expect(centres["tile"]).to be_within(1).of(centres["firstLine"])
    expect(centres["dismiss"]).to be_within(1).of(centres["firstLine"])
  end
end

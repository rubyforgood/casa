# Announcement banner — design preview

The images below are rendered from the app's own preview pages, with the real `tailwind.css`. They are
checked in so the design can be reviewed without running anything; if you *do* have the app running,
the live, interactive versions are at

- <http://localhost:3000/rails/view_components/announcement_banner/shipped>
- <http://localhost:3000/rails/view_components/announcement_banner/lead_variants>

(index: <http://localhost:3000/rails/view_components>)

The preview source is `spec/components/previews/announcement_banner_preview.rb`. `shipped` renders the
**real** `app/views/layouts/_casa_banner.html.erb`, so it cannot drift from what the app serves.

## Shipped

![The shipped announcement banner: a 4px amber-600 left accent band, a plain megaphone glyph, the
message, and a Dismiss link — shown full width, at 390px, and beside the icon tile it
replaced](banner-shipped.png)

- 4px `amber-600` **left accent band** — 3.07:1 against the amber-50 bar, so it clears the 3:1 WCAG
  1.4.11 asks of a meaningful graphic. `amber-500` measured 2.07:1 and read washed.
- A **plain** `bi-megaphone` glyph inheriting the bar's `amber-900` (8.73:1), `text-base leading-5`,
  nudged `mt-0.5` so its ink centres on the text's x-height band rather than its box centring on the
  line box.
- **47px** tall. The third row in the image is the icon tile this replaced: 57px, and the eye goes to
  the square instead of the sentence.

## Typographic lead — proposals, not built

![Eight variants of the banner: content only, bold name with period, colon, em dash and no
punctuation, an admin-shorthand name, the title on its own line, and rich text with two paragraphs
forced inline — each shown full width and at 390px](banner-lead-variants.png)

`Banner` has both a `name` and a rich-text `content`; the bar renders only `content` today. The rows
show what `name` as a bold lead would look like.

| row | desktop | 390px |
|---|---|---|
| A content only (shipped) | 47px | **85px** |
| B bold name + period | 47px | 105px |
| C bold name + colon | 47px | 105px |
| D bold name + em dash | 47px | 105px |
| E bold name, no punctuation | 47px | 105px |
| F admin-shorthand name | 47px | 105px |
| G title on its own line | 65px | 105px |
| H rich text, two paragraphs, forced inline | 47px | 130px |

The pattern is standard — *title + supporting text* in Bootstrap alerts, Primer flash, Carbon inline
notification, Atlassian SectionMessage, Polaris Banner — but three things are worth deciding with the
image in front of you:

1. **It costs a line on mobile.** Free on desktop, +20px at 390px (85 → 105).
2. **`name` is an admin label today**, not user-facing copy — row F shows a real risk ("sept banner test
   2. Quarterly court reports are due…"). Adopting any of B–F means relabelling that field in
   `banners/_form` and accepting that older rows read oddly until edited.
3. **`content` is ActionText**, so it is block HTML. Row H fits on one line only because the
   `.trix-content` children are forced inline — and then the author's paragraph break disappears and
   the two paragraphs run together as one sentence. A bulleted list collapses the same way.

**Recommendation:** C (colon) if the lead is wanted — a colon marks `name` as a label, where a period
makes a noun phrase read as a sentence. If most volunteers read announcements on a phone, A as shipped
is the better trade, since the accent band already gives the bar its presence.

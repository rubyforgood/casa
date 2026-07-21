# CASA Design System

> **Permanent, living record** of the CASA UI refresh (`casadesign` branch) — the
> **single source of truth** for the new design system and the decisions behind it.
> **Refer to it for all UI work** so this direction never has to be rediscovered or
> rebuilt. Read it before building UI, and keep it current as patterns solidify.
> The live "what's left" backlog lives in [`design-todo.md`](design-todo.md).

## Status & approach

Migrating the UI to **Tailwind CSS v4** with a clean, modern look (reference points:
Stripe, Airbnb — calm, trustworthy, generous whitespace).

Tailwind runs **alongside the legacy Bootstrap 5 UI**. Migrate **page-by-page**:
new/redesigned screens use a Tailwind-only layout; untouched screens keep the
Bootstrap `application` layout. Never load both CSS resets on the same page.

- Tailwind source: `app/assets/stylesheets/tailwind.css` (CSS-first `@theme`).
- Build: `npm run build:tailwind` (one-off) / `build:tailwind:dev` (watch); the `tw`
  process in `Procfile.dev` runs the watcher. Output -> `app/assets/builds/`.

## Foundations

### Typography
- **Figtree**, weights 400/500/600/700/800. Warm humanist sans. Self-hosted (latin + latin-ext
  woff2 under `public/vendor/figtree/`; `@font-face` in `app/assets/stylesheets/vendor/figtree.css`,
  `@import`ed by `tailwind.css`) — no CDN.
- Scale:
  - Page title (h1): `text-2xl font-bold tracking-tight text-slate-900`
  - Section title (h2): `text-base font-semibold text-slate-900`
  - Body: `text-sm text-slate-600`
  - Label: `text-sm font-medium text-slate-700`
  - Muted / meta: `text-xs text-slate-500` (never `text-slate-400` for text — fails AA)

### Sentence case
All UI copy — page titles, section headings, subtitles, table headers, field labels,
buttons, badges and nav — uses **sentence case**: capitalise only the first word and
proper nouns (CASA, Twilio, people's names). So "Track volunteer progress", not "Track
Volunteer Progress" and never the shouty all-caps "TRACK…". Do **not** apply the
`uppercase` CSS transform to labels; use size, weight and colour for hierarchy instead.

**No trailing colon on a heading or subtitle** (`Assigned volunteers`, not `Assigned
Volunteers:`; `Current placement`, not `Current Placement:`). A colon belongs only on an
inline key:value **fact label** (a `dt` such as `Court report status:`), never on a section
title. Audit the views you touch: `grep '<h[123][^>]*>[^<]*:</h'` should return nothing on a
casa_app page.

Sentence case also covers **app-shipped content**, not just view copy: seed defaults and
constants (e.g. `ContactTypeGroup::DEFAULT_CONTACT_TYPE_GROUPS`, whose names render as the
multiselect chips) are sentence-cased too. Before finishing, **scan the touched views and any
app-shipped names/defaults for Title Case or ALL-CAPS** and fix them. Proper nouns and
acronyms (CASA, IEP, Twilio) are the exception, and never force-case free-form org data (an
org may legitimately name a type "ADHD coach"). Sentence-casing a **default constant** does
**not** fix orgs already seeded from the old names — `generate_for_org!` find_or_creates by name
and never renames — so pair the constant change with a one-time after_party rename that touches
only case-variants of a shipped default and leaves org-renamed / custom names alone
(`20260721000000_sentence_case_default_contact_types`).

### Color
Brand = indigo. Neutrals = slate. Semantic colors below.

| Token | Value | Use |
|---|---|---|
| brand-50…900 | indigo `#eef2ff`…`#312e81` | primary actions, active nav, accents |
| slate-50…900 | neutrals | text, borders, surfaces |
| emerald | — | success / "on track" |
| amber | — | warning / notices |
| rose | — | danger / "needs follow-up" |
| sky, violet, teal | — | avatar / accent variety |

Brand scale lives in `tailwind.css` `@theme` as `--color-brand-*`.

### Spacing, radius, elevation
- 4px spacing base (Tailwind default).
- Radius: controls `rounded-lg`; cards/panels `rounded-2xl`; icon tiles `rounded-xl`.
- Surfaces: white, `border border-slate-200`, `shadow-sm`.
- Page background: `bg-slate-50`.
- **Page vertical rhythm** (index / list pages): content wrapper `px-4 py-6 sm:px-6 lg:px-8`;
  header block `mb-6` (24px); a plain (borderless) filter bar gets `mb-4` so it sits **16px**
  above the table — every roster filter converges on this (cases / volunteers / supervisors /
  reimbursements all measure 16px; `mb-5` or `mb-6` on a *plain* filter is drift). A filter
  wrapped in its own bordered `rounded-2xl` card (case-contacts) is a *section*, so it keeps the
  24px (`mb-6`) section gap instead. Stacked sections/cards separate by 24px (`mt-6` / `mb-6`);
  the metrics dashboard (range filter + three chart cards) is one uniform 24px column, and the
  range filter carries `mt-6` so it clears the KPI row / subtitle above it (it butted flush at
  0px before). A **bulk-action trigger** that reveals on selection (the volunteers Manage button)
  puts `mb-4` **on the button**, **never a reserved `min-h` band** — a reserved band leaves a
  persistent ~68px empty gap above the table while nothing is selected; let the button push the
  table down only once a row is picked (the `select-all` controller toggles `hidden!` on the
  button, which collapses its margin too). Pagination rendered **inside** the table card needs no
  top margin (the `shared/_pagination` bar owns a `border-t` + `mt-1`); rendered **below** the
  card, wrap it in `mt-4`. Verify these gaps at the pixel level (filter-bottom -> table-top), not
  by reading tokens.

### Iconography
- **Bootstrap Icons** (`bi-*`), self-hosted: font binaries under `public/vendor/bootstrap-icons/`,
  CSS vendored at `app/assets/stylesheets/vendor/bootstrap-icons.css` and `@import`ed by
  `tailwind.css` (no CDN). Vendored from the `bootstrap-icons` (icons) + `@fontsource/figtree`
  (font) npm packages via `npm i --no-save`, with `url()` rewritten to the `public/vendor/` paths.
- **Icon tile pattern** — icons representing a *stat or status* sit on a soft
  colored rounded background:
  `grid place-items-center h-9 w-9 rounded-xl bg-{semantic}-50 text-{semantic}-600`.
  Use for KPI cards, section headers, and list-item leading icons.
  **Do not** use bare floating icons or ringed white "avatar" circles for status
  contexts — reserve initial-avatars for representing *people* only.
- **Leading-icon alignment** — an icon that precedes a label (menu items, list rows) is
  **top-aligned to the first line** (`items-start`), like a list marker, never centered
  against a wrapped block. Single-line labels look identical either way; `items-start` keeps
  it correct once a label wraps. (Material and Primer both top-align multi-line leading
  elements.)

### Accessibility (WCAG 2.1 AA)
Everything ships to **WCAG 2.1 AA** — it's part of "done", not a follow-up.
- **Contrast** ≥ 4.5:1 for text (3:1 for large ≥24px/bold text and for UI borders/icons).
  Muted text is `slate-500` on white — **not `slate-400`, which fails AA** — and
  `slate-600` on tinted surfaces. Never signal meaning by colour alone; pair a status
  colour with an icon or word.
- **Structure**: one `h1` per page, in-order headings, landmarks (`main`/`nav`/`aside`),
  real lists, and `<caption>` + `scope` on tables.
- **Forms**: every control has a real `<label>`; the error summary uses `role="alert"`
  and names the field; invalid/required state is never colour-only. A control with an
  **overridden id** or a **JS-enhanced widget** (a TomSelect multiselect, the month/year
  `select_tag`s) needs an explicit accessible name — point the `<label for>` at the *actual*
  rendered id, or set `aria-label` — because the default `for` no longer matches and axe's
  `select-name` rule then fails. Guarded by `spec/system/accessibility/axe_spec.rb`.
- **Keyboard & focus**: fully keyboard-operable, visible `focus-visible` rings, a skip
  link, logical order; icon-only controls carry an `aria-label`, decorative icons are
  `aria-hidden`.
- **Motion**: respect `prefers-reduced-motion` (`motion-reduce:` variants).

## Components

### Buttons
Use the **`button_classes(:variant)`** helper (`DesignSystemHelper`) as the single source of
truth. Never hand-write button class strings in views; they drift (that is how the variants
ended up mismatched). Variants:
- `:primary` (filled brand): `bg-brand-600 text-white font-semibold hover:bg-brand-700`
- `:secondary` (outlined): `border border-slate-200 bg-white text-slate-700 font-medium hover:bg-slate-50`
- `:danger` (filled rose): `bg-rose-600 text-white font-semibold hover:bg-rose-700`
- `:danger_outline` (outlined rose): `border border-rose-200 bg-white text-rose-700 font-medium hover:bg-rose-50`
- `:success` (filled emerald, for positive / resolve actions): `bg-emerald-700 text-white font-semibold hover:bg-emerald-800` (emerald-700, not 600: white on 600 is 3.77:1, below AA)

Every variant shares a base of `inline-flex h-10 items-center justify-center gap-2 rounded-lg
px-4 text-sm shadow-sm` plus a `focus-visible` brand ring and `disabled:` states. The fixed
**`h-10` (40px) height token** is deliberate: with `box-sizing: border-box` it absorbs the
outlined variant's 1px border, so filled and outlined buttons are the same height by
construction (40px is the mainstream medium-button height: Material 3, Chakra, shadcn). **Do
not** re-equalize sizes with `border border-transparent` on the filled variants; that is a
fragile compensation pinned to the secondary's exact border width, and the height token
already handles it.

- Tertiary (ghost): `rounded-lg px-2 py-1 text-sm font-medium text-slate-600 hover:bg-slate-100 hover:text-slate-900`.
  No border, fill, or shadow: the lowest-emphasis action, for repeated row / toolbar actions so they recede from brand
  links. Not part of `button_classes` (it is a low-emphasis action, not a CTA). Neutral ink stays at or above AA
  (slate-600 is about 7:1; never `slate-400` under visible text). Leading icon via `gap-1.5` plus a `bi-*` glyph.
  Right-aligned in a table's trailing actions cell, give that cell extra end padding (`pr-6`) so the control clears the
  card edge rather than skewing the button's own padding.

**Audit before shipping:** grep the views you touched for clickable elements (`link_to` /
`button_tag` / `button_to` / `<button` / `<a`) carrying a hand-rolled button shape
(`inline-flex` + `rounded-lg` + `px-`/`py-` + `bg-`/`border-`) and convert them to
`button_classes`. A bespoke string at `py-1.5` next to a 40px token is the recurring drift
bug; the only non-`button_classes` clickable is the documented tertiary ghost.

### Inputs
`block w-full rounded-lg border border-slate-300 px-3.5 py-2.5 text-slate-900 shadow-sm placeholder:text-slate-400 focus:border-brand-500 focus:ring-2 focus:ring-brand-500/30 focus:outline-none`

### Select
A native `<select>`, but the browser's arrow is replaced with a Bootstrap-icon chevron so it
looks the same across browsers and matches the app's other dropdowns (the cases-index filter
is the reference). Wrap the select in a `relative` div and overlay the chevron:

```erb
<div class="relative">
  <%= form.select :field, options, {}, class: "block w-full appearance-none rounded-lg border border-slate-300 bg-white py-2.5 pl-3.5 pr-9 text-sm text-slate-900 shadow-sm focus:border-brand-500 focus:ring-2 focus:ring-brand-500/30 focus:outline-none" %>
  <i class="bi bi-chevron-down pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 text-xs text-slate-500" aria-hidden="true"></i>
</div>
```

`appearance-none` hides the native arrow, and **`pr-9` is required** so the value never
crowds the chevron: a plain `<select>` with `px-3` collides the text with the native arrow.
Chevron ink is `slate-500` (AA). Month/year pickers reuse this through
`casa_cases/_month_year_select` (it keeps Rails' `_1i`/`_2i` date-part field names).

### Form layout
Forms use a **two-column responsive grid**: `grid grid-cols-1 gap-5 sm:grid-cols-2`, which
collapses to one column below `sm`. Wide fields (case number, a multiselect) get
`sm:col-span-2`; compact fields (dates, a status select, a single-value select) take one
column. Keep to just two widths, full and one-column, so it does not look loose. The submit
is a single primary button at the **bottom** (no top CTA on a fill-then-save form), verb-first
and sentence case ("Create case", "Save changes"). Month/year pickers use
`casa_cases/_month_year_select`.

A **section heading** inside a form card (e.g. "Court details") lives **outside** the
grid, not as a grid child, so it does not inherit the uniform `gap-5` on every side. Give
the heading `mb-3` (12px) so it hugs the fields it introduces, and put the field above it
(e.g. case number) in its own block with `mb-6` (24px) for section separation. A heading
left as a grid child floats with equal 20px above and below and reads as detached.

**Simple settings CRUD forms** (the org-settings long-tail — judges, languages, placement types,
learning-hour types/topics, and other name(+active) resources) share one partial,
`shared/_settings_form` (locals: `model`, `title`, `show_active`, `description`). It renders the
casa_app page shell + a card with a required name field, an optional `Active?` checkbox, an
optional intro paragraph, and a Submit button; `form_with model:` infers the url + param key.
The resource's `_form` is a one-line `render`, and its controller sets `layout "casa_app"` +
`@active_nav = "settings"`. No breadcrumb (keeps it free of `current_organization`, so the
no-layout view specs render it standalone); save redirects back to the settings page.

### Rich text (Trix)
ActionText `rich_text_area` fields work on casa_app because `tailwind.css` `@import`s
`trix/dist/trix.css` alongside `tailwindcss` + tom-select. Trix's styles otherwise ship only in
the legacy `application` bundle, which casa_app does not load — without the import the toolbar is
unstyled and blows the page width to ~900px on every screen. Trix's default `.trix-button-row`
is `overflow-x: auto`, so once loaded the toolbar self-scrolls on narrow screens (the page fits;
the measure script surfaces the contained button row like a scrolling table). Give the editor
design-system chrome via `class: "trix-content rounded-lg border border-slate-300 shadow-sm"`.
The banner form is the reference.

### Multiselect
Both the rich `Form::MultipleSelectComponent` (select-all + filterable list) and the basic
`multiple-select` Stimulus controller render TomSelect, themed in `tailwind.css` (casa_app
only; Bootstrap pages keep the tom-select.bootstrap5 theme):
- **Loads blank**: it defaults to an empty field with a placeholder (`Select or search
  <term>`), **never pre-selected with every option**. `show_all_option` still offers
  `Select/Unselect all` in the menu. (Contact types is required, so blank plus the "at least
  one contact type" validation is the correct required-field UX; it is not a reason to
  default-select everything.)
- **Chevron**: the Bootstrap-Icons `chevron-down` shape as a `.ts-wrapper::after` **base64-SVG**,
  sized (`text-xs`) and placed (`right-3`) to **match the single-select chevrons**, with
  **`z-index: 2`**. The z-index is the crux: TomSelect's opaque `.ts-control` paints over a plain `::after`, so the caret is
  present but hidden without it (that stacking, not a missing rule, is why the chevron read as
  "missing" for so long). Do not use a CSS `content` glyph escape (the minifier drops it), a
  raw non-base64 `data:` URI (broke in the build), or an injected CDN icon-font element (never
  painted). **Verify a chevron at the pixel level** (screenshot + darkest-pixel), never by
  computed style, which reports the element as present even when nothing paints.
- **Chips** are brand-100 pills, brand-700 text (6.4:1), each with a visible × (the
  component's LineIcons X and grey divider are overridden for casa_app).
- **Flip-up**: the controller's `onDropdownOpen` adds `.ts-flip-up` when the control is near
  the viewport bottom, so the menu opens above and stays on screen.
- Override tom-select at `.ts-wrapper.multi` specificity (and `!important` where it uses it);
  its default grey theme wins otherwise.

### Nested sub-form (repeatable rows)
The court-orders sub-form (`casa_cases/_court_orders` + `_court_order_fields`) is the
pattern: repeatable `.nested-form-wrapper` entry rows, an **Add** button that clones a
`<template>` (`court-order-form#add`), and a per-row **Delete** (`danger_outline`). Each row
is a full-width textarea + a one-column design-system status select + Delete, in a
`flex-col sm:flex-row` bordered card (`rounded-lg border p-3`). Copy-from-sibling is a
select + Copy button with a Dialog confirm (the `copy-court-orders` controller PATCHes
`copy_court_orders`, then reloads so the copied orders and the flash show).

### Autosave wizard form (case-contact)
The case-contact form (`case_contacts/form/details`, a Wicked single-step wizard) is the
reference for a long **autosave** form on the shell. Render it by setting `layout "casa_app"` on
the controller — `render_wizard` / `render step` pick it up, while the autosave JSON responses
skip the layout automatically. Structure: Tailwind card sections (Details / Notes / Reimbursement)
in one `max-w-3xl` column, plus a bottom action bar (a "Create Another" checkbox + the primary
Submit). Three Stimulus contracts must survive a restyle **verbatim**:
- **autosave** — `data-controller="autosave"` on a wrapper *outside* the `<form>`;
  `data-autosave-target="form"` on the form; `data-action="input->autosave#save"` on each text
  field that should autosave (notes, topic answers, expense descriptions — *not* the whole form);
  and a `<small role="alert" data-autosave-target="alert">No changes have been saved.</small>`
  status line per section (that literal text is asserted by a non-JS spec; the JS swaps in
  "Autosaving…" / "Saved!" and toggles `invisible` / `visible`, both real Tailwind utilities).
- **casa-nested-form** (repeatable rows; extends stimulus-rails-nested-form) — each row is a
  `.nested-form-wrapper` with `data-casa-nested-form-target="wrapper"`, `data-new-record`,
  `data-child-index`, and hidden `id` + `_destroy` fields; the container holds a `<template>`
  target, the existing `fields_for` rows, an empty `target` div (new rows insert *before* it), and
  an **Add** button (`casa-nested-form#addAndCreate`). Rows autosave-create on add and
  autosave-destroy on delete. (This differs from the court-orders `court-order-form#add`, which
  only clones client-side.)
- **case-contact-form** — reveals the reimbursement sub-form by toggling Tailwind **`hidden`** (the
  controller was switched off Bootstrap `d-none`, which Tailwind does not define; safe because only
  this form uses the controller). Keep it initially `hidden` so the non-JS `have_no_field` specs
  pass and rack_test (ignores CSS) can still reach the fields.

Required-field markers are `tag.span("*", class: "text-rose-600", "aria-hidden": "true")` — **not** a
`.html_safe` string literal, which erb_lint rejects as unsafe interpolation. Shared bits stay shared:
relevant-case picking is `Form::MultipleSelectComponent` (TomSelect) and errors use
`shared/form_errors`; only the form-private partials (`_contact_topic_answer`,
`shared/_additional_expense_form`) are restyled in place. Duration is an inline Tailwind twin, like
learning hours (`Form::HourMinuteDurationComponent` is now dead).

**Relevant case(s) is read-only when editing an active contact** (`@case_contact.active?`): the
model requires `draft_case_ids`, and on edit the picker only ever offered the one case the contact
belongs to, so a removable multiselect there just lets the user dismiss a required, fixed parent.
On edit, show the case number(s) as a **badge beside the `Details` heading** (fixed context, not a
faux form field) plus hidden `draft_case_ids`, and left-align the lone date field below it; keep
the `#draft-case-id-selector` id for the JS/spec contract. Keep the TomSelect multiselect (paired
with the date in the 2-col grid) only for new / draft contacts. The per-contact-type recency hint
under each checkbox reads **"Last logged N ago"** and is **omitted when never logged** — a bare,
unlabeled "never" under every unused type read as a mystery state; `ContactTypeDecorator`
exposes `#last_logged_hint_with_cases` (nil for never) for the form while `#last_time_used_with_cases`
still returns "never"/"N ago" for the contact-type multiselect subtext. **Notes is a fixed-topic checklist**
(`_contact_topic_answer`): every org topic is a `border-t`-divided row of a checkbox + the topic
question, with a full-width notes textarea revealed on check — no dropdown, no nested cards, no
"Add another" button. The `contact-topics` controller **creates** the answer on check (POST
`/contact_topic_answers`, storing the returned id) and **destroys** it on uncheck (a confirm if
notes exist); the 2s autosave then only *updates* the value via that id. Because create/destroy is
explicit, `CaseContact` rejects id-less topic-answer attrs (`reject_if: id blank`) so a slow
autosave can't create a duplicate, and `form_controller#prepare_form` must NOT seed a blank answer
(it would orphan a nil-topic row). Associate each checkbox's label with `for` (not by wrapping),
or a click double-fires `change` and creates the answer twice. This replaced the old dropdown +
per-row Delete: the dropdown was redundant against a fixed topic set, and **unchecking is a clearer
"remove"** than a Delete button (which read as clearing the field).
**Collapsible section padding:** a section's autosave status line goes *inside* the collapsible
body it reports on (the Reimbursement form), so the collapsed/empty state is just heading +
checkbox and doesn't reserve a blank `invisible` line at the bottom — that reserved line made the
empty reimbursement card look over-padded vs the others (same `p-6`, ~40px of dead space). The
autosave status is also toggled by **display** (`hidden` ⇄ `block`, not `invisible`/visibility), so
an idle card reserves no line and Notes/Reimbursement match the Details card's bottom padding.
**Nested expense rows** are separated by a **divider** (`border-t border-slate-200`) with symmetric
`py-4` so the Delete never sits flush against the next line, and **stack vertically with visible
labels** (`space-y-4`): amount, then description (required), then a right-aligned `Delete` below —
not a grey `bg-slate-50` box. The wrapper keeps `.nested-form-wrapper` + its data hooks. Deleting a
**saved** expense goes through the design-system confirm dialog (new/unsaved rows remove without a
prompt).
**Structured mailing address:** captured as discrete parts (line 1 / line 2 / city / state / zip),
not one free-text field. `Address` keeps `content` as the canonical composed one-line string every
reader still uses (reimbursement table, mileage CSV, case-contact prefill): `Address.compose(...)`
plus a `before_save` that runs only when `structured?`, so legacy content-only rows and the factory
stay untouched. The reimbursement card reuses the same parts as five virtual attrs on `CaseContact`
that compose into the `volunteer_address` snapshot (`compose_volunteer_address`, skipped when all
parts are nil so the legacy single-string path — request specs, factory — still sets it directly;
a blank submit yields `""` so the reimbursement-wanted validation still fires). Prefill the fields
from the volunteer's structured Address (`decorate.volunteer_address_parts`) and give each a
`volunteerAddress` Stimulus target so `clearMileage` empties them all on uncheck. Layout: line 1 /
line 2 full-width, then city (col-span-3) · state (1) · ZIP (2); sr-only labels + placeholders.

### Sharing a partial with Bootstrap
When a partial is still rendered by legacy Bootstrap pages (e.g. `shared/_court_order_list`
on the court-date pages, `shared/_edit_form` / `_invite_login` on the casa_admin edit page), do
**not** restyle it in place: Tailwind classes render unstyled on Bootstrap and the reverse. Add a
**casa_app-specific Tailwind twin** (`casa_cases/_court_orders`, `casa_cases/_volunteer_assignment`,
`supervisors/_manage_volunteers`) that preserves every JS hook (ids, classes, data-actions, field names, and any DOM
adjacency the JS relies on). A legacy global-jQuery flow (copy-from-sibling) can instead be
reimplemented as a small Stimulus controller on the twin, leaving the jQuery and the shared
partial untouched for the Bootstrap pages.

### Card / panel
`rounded-2xl border border-slate-200 bg-white shadow-sm` (pad `p-5`).
A **content card with a leading icon** (the case-contact card) puts the icon **in the header
row** next to the title (`card-title flex flex-wrap items-center gap-2` + a 32px `h-8 w-8`
rounded-xl icon tile), **not** as a full-height gutter beside the whole body. An `items-start`
icon column indents *every* body line behind it — the case-contact card read as pushed ~48px
right, with the answers/notes hanging off the icon instead of the card edge. With the icon in
the header, the body (secondary text, answer list, actions) spans the card's full width,
left-aligned to the `p-5` edge (measured: body indent 48px -> 0). Decorative status glyphs are
never data: the transition-aged 🦋/🐛 emoji is dropped from the case-number heading (plain
number), per the Tables note.
**Type hierarchy inside a card:** the title is the only `text-base font-semibold` (slate-900)
element; every supporting / detail line is `text-sm`, and **no body line may out-weigh the
title** (a detail line once rendered `text-base font-bold` and made the body shout over the
title). Confirm the title (16px / 600) stays the sole anchor with computed style, not by eye.
**Progressive disclosure, not per-line truncation:** collapsible detail (the case-contact card's
topic answers + notes) goes in **one** native `<details>` "Show details" toggle that reveals the
whole block at full length — a `dl` of `text-xs font-semibold text-slate-500` `dt` +
`text-sm text-slate-700 whitespace-pre-line` `dd`, matching the new-design table's expandable
detail. **Never** give each line its own truncate + `read more`: reading a single note then cost
several clicks (the recurring "excessive truncation" bug). The `<summary>` swaps Show/Hide via
`group-open:` and is a `brand-600 font-medium` link with the marker hidden
(`[&::-webkit-details-marker]:hidden`).
**Dividers, not nested cards:** don't box a card's revealed detail in its own `rounded-xl border`
panel — a card inside a card isn't a pattern in this app. Separate the disclosure with a
`border-t border-slate-100 pt-3` rule on the `<details>` (as `metric_data_table`'s "View as
table" does) and render the `dl` unboxed. `border-b` *under the title* likewise over-segments a
compact card; structure comes from that detail divider and the footer `border-t`. WCAG: the
native `<details>`/`<summary>` carries its own expanded/collapsed semantics (keyboard + SR), the
chevron is `aria-hidden`, and the `brand-600` summary + `slate-500` labels clear AA on white.

### Fact / detail list
Entity facts (the case-details card) are inline `dt` (muted `font-medium text-slate-500`) :
`dd` (dark `text-slate-800`) pairs. Put any **derived / secondary** value (a relative
duration, a submitted-at timestamp) on a **muted second line** (`mt-0.5 text-xs
text-slate-500`), never as a light suffix after the dark value on the same line as the light
label: light-dark-light on one line reads as broken. Keep the "Label:" wording (specs match
it) and reword derived text to be self-explanatory ("In care for over 8 years", not
"(over 8 years ago)").

### Table (in a card)
Full-bleed table inside an `overflow-hidden rounded-2xl` card: a header row
(`border-b border-slate-100 p-4`), then `thead`/`tbody` with cells `px-4 py-3` and
`divide-y divide-slate-50` between rows. Add `pb-2` to the card so the last row clears
the rounded bottom corner instead of butting against it (use `py-2` for a header-less
list card — e.g. notifications — so the first row clears the top corner too). Keep rows
a uniform height (a taller last row reads as a bug).

### Tables (bespoke) + pagination
Hand-built Tailwind (dashboard tables + cases index), not DataTables. `overflow-hidden
rounded-2xl` card (+ `py-2` inset), full-bleed table, `thead th` = `text-xs font-semibold
text-slate-600` — **never an `uppercase`/`tracking-wide` transform** (column headers are sentence
case like every other label; an ALL-CAPS `text-slate-500` eyebrow header is a recurring drift — it
had crept into the reimbursements / settings / court-date / placements / all-CASA tables — converge
every `<th>` on this one token, matching what `sortable_header` emits). Header and body cells share the same `px-4 py-3` padding (so columns line up), and every `<th>`
is `align-top` — a column whose header wraps to two lines then anchors all headers to one top line
instead of vertically-centring the single-line neighbours (the browser `vertical-align: middle`
default, which reads as stray space). `divide-y divide-slate-50`, `hover:bg-slate-50/70`.
Keep the `thead` even when empty and put an empty-state row in the `tbody`. Filtering /
sort / pagination are **server-side** (params + Pagy); the filter bar is plain selects that
submit on change (`auto-submit` controller). Pagination: the `shared/_pagination` partial
renders a Pagy instance as a bottom bar — "Showing X–Y of Z" left, page controls right
(`nav` + `aria-label`, `aria-current`, `rel=prev/next`), preserving filter params. Don't render
decorative emoji as data (e.g. the 🦋/🐛 transition-aged icons) — use a plain label or pill.
Verify a column's data source before carrying one forward: the legacy cases index kept
Hearing Type / Judge columns that had rendered blank for every case since a 2023 migration
moved that data onto court dates — drop dead columns or re-source them (the migrated index
shows "Next court date" instead).

**Responsive:** render the full table in `hidden md:block` and a stacked-card list below `md`
(`md:hidden`, one card per row with a `<dl>` of labeled fields). A data table never relies on
horizontal scroll alone. When a spec asserts a table hook (e.g. `.notes .table tbody tr` on the
volunteer edit page), keep the `<table>` in the DOM as `hidden md:block` rather than dropping it
below `md`: rack_test ignores the `hidden` class, so the hook holds at every width while the
`md:hidden` card twin serves phones. The exception is a density **matrix** (the contact-timing heatmap on Metrics/Analytics), which keeps
horizontal scroll with a sticky axis column (`sticky left-0 z-10 bg-white`); stacking a 2D matrix
into cards would destroy the visualization.

The **org-settings / checklist admin tables** (rendered inside a white section card) use a
**compact** `md:hidden` twin — `rounded-xl border border-slate-200 p-4` cards (lighter than the
top-level `card`): the primary column as a `font-medium text-slate-800` line, other columns in a
`<dl>` (`flex justify-between` rows; multi-line values like Details / URL stacked with
`whitespace-pre-line` / `break-all`), then Edit / Delete in a `border-t` footer. Keep the `<tr id>`
and per-row `shared/_confirm_button` on the **table only** — the card omits the id (it's a `<dl>`,
not a row) and a duplicate confirm_button is safe (each Dialog is scoped by its own
`data-controller="modal"` wrapper, id nil, so nothing collides). A table already narrow enough to fit
a phone with no horizontal scroll (the 2-column emancipation-checklists index, measured W360/375)
keeps its plain table — the rule targets scroll, not tables.

When the container is **narrow** and each row has many fields (e.g. the volunteer assignment
list inside the edit column), use a **card list at all widths** (one `<li>` per record: name +
status pill on the first line, a `<dl>` of labeled meta, then the row actions) instead of
squeezing a wide table into a narrow column.

**Retiring a jQuery DataTable** (cases index, volunteers index): reuse the page's `*Datatable`
query **server-side** rather than its JSON protocol. The volunteers index maps its plain GET
filters into the DataTables param shape and calls `VolunteerDatatable#index_relation` /
`#index_count` (the count strips the custom `SELECT`/`ORDER` aliases AR's `COUNT` can't wrap and
counts `DISTINCT users.id`). Crucially, **don't reuse the id `dashboard.js` targets**: it runs
`$('table#volunteers').DataTable(...)` on DOM-ready and would re-init a server-side DataTable
over the migrated markup (its `ajax.url` is undefined → a stray `POST` to the index). Put the
spec's `#volunteers` hook on the table's **wrapper `<div>`**, not the `<table>`, so the legacy
selector misses and the block no-ops (the filter handlers key off the old checkbox classes and
no-op too). The unused JSON action + dashboard.js block are then dead (queue for cleanup).

**Roster with bulk actions** (volunteers index): a hidden **Manage** trigger (`select-all`
controller) reveals on selection, opens a native-dialog modal (`modal` controller) whose submit
is gated by the `disable-form` controller. Put the row checkboxes in the **desktop table only**
(one `data-select-all-target="checkbox"` per record, so counts/`find` stay unambiguous); bulk
editing is a desktop tool. To hide a `button_classes` trigger, toggle **`hidden!`** (Tailwind v4
important), not `hidden`: a plain `hidden` loses to the button's `inline-flex` in the cascade
(the display utilities have equal specificity, so order decides and `inline-flex` wins).

**Expandable rows + inline row actions** (the case-contacts new-design table, the third
bespoke-table reference). A row that reveals detail (topic answers + notes) is a **separate
`<tbody>` per row** (valid HTML — a table may have many) wearing `data-controller="disclosure"`:
the main `<tr>` holds the toggle (`disclosure#toggle` + a `trigger` target, a chevron that spins via
`group-aria-[expanded=true]:rotate-180`) and a hidden detail `<tr data-disclosure-target="panel">`
holds the `<td colspan>` panel. Give the `<table>` `border-collapse` so the per-`<tr>` `border-t`
separators render across the multiple tbodies. **Row actions stay inline** (icon ghost buttons +
the native Dialog:: suite for the delete confirm / set-reminder note), **never a per-row
`<details>` dropdown**: an absolutely-positioned dropdown is clipped by the table's
`overflow-x-auto` (which also forces `overflow-y: auto`), whereas a native `<dialog>` opens in the
top layer and escapes the clip. Render the actions once as an `_actions` partial with `layout: :row`
(desktop icon buttons) / `:bar` (the mobile card's labeled buttons); duplicate Dialog instances
across the two twins are safe (each is scoped by its own `modal` controller). A row-level state
indicator (the amber `bell-fill` "Reminder set") lives in a data cell, independent of the
permission-gated action. Set/Resolve reminder and delete return via `redirect_back_or_to` /
`redirect_to request.referer`, so the action stays on the list rather than jumping to the case page.

### Charts (data viz)
Charts are **bespoke server-rendered SVG** (no canvas, no Chart.js), built in `MetricsHelper`
and rendered on the all-CASA **Metrics** console (platform-wide) and the per-chapter **Analytics**
page (org-scoped) -- both reuse the shared `metrics/_dashboard` partial and get their numbers from
`MetricsReport` (scope-parameterized: global by default, `casa_org:` for one chapter). Validated
with the data-viz method:
- **Series identity is never color alone.** Each line carries a distinct **line style**
  (solid, dashed, dotted, dash-dot) **and marker shape** (circle, square, triangle, diamond)
  on top of a validated categorical palette (indigo, emerald, amber, rose; worst adjacent
  CVD deltaE 31.3, all AA on white). The legend shows the line + marker key, not a swatch.
- **A table twin per chart:** a `<details>` "View as table" with a real `<table>` (scope
  headers); the SVG carries `role="img"` + `<title>` / `<desc>`; no value is color-only.
- **Heatmaps are accessible tables:** a day x hour grid as a `<table>` with a sequential
  single-hue background and the count in every cell (color plus number).
- **Marks:** 2px lines, hairline solid gridlines, markers with a 2px surface ring, direct
  end-value labels, muted axis ink (slate-500 / 600, AA).
- **Totals live in stat tiles, never a row sum.** Correct range totals only (sums for
  additive metrics, a distinct count for unique loggers, footnoted). Never sum
  non-additive columns.
- **States:** a genuine zero shows a muted `0`; a missing value shows "No data" (never a
  fake 0); a section with no data swaps in an empty state; loading uses skeletons; error is
  distinct with a retry.
- Palette checked with the data-viz skill's `validate_palette.js`. Dark mode is deferred
  (off-the-shelf Tailwind steps miss the dark lightness band; needs hand-tuned OKLCH).

### KPI stat card
Semantic icon tile (`grid h-9 w-9 place-items-center rounded-xl bg-{hue}-50 text-{hue}-600`) ->
number (`text-3xl font-bold tracking-tight text-slate-900`) -> label (`text-sm text-slate-500`) ->
optional meta (`text-xs text-slate-500`, not slate-400 -- the contrast audit bumped readable
slate-400 to AA slate-500). One shared token across the admin/supervisor/volunteer dashboards and
the Analytics page. Two accented variants: **danger** (e.g. unassigned cases) = rose number + rose
icon tile + `ring-1 ring-rose-100`; **attention** (e.g. cases needing contact) = slate number but
the icon tile flips to amber (`bg-amber-50 text-amber-600`) when positive, emerald when zero. A
**trend delta** (Analytics "contacts this month") is the meta line, colored emerald/rose/slate for
up/down/flat with a direction arrow + signed number + "vs last month" (never color-only).

### Status pill
Base: `inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-medium`
- On track: `bg-emerald-50 text-emerald-700` + check icon
- Needs follow-up: `bg-rose-50 text-rose-700` + exclamation icon
- Neutral / deactivated: `bg-slate-100 text-slate-600` + minus icon (**slate-600**, not
  slate-500: on the slate-100 tint slate-500 is only 4.34:1, below AA; slate-600 is 6.92:1)

Volunteer assignment reuses these three: Assigned (emerald), Unassigned (rose),
Deactivated volunteer (slate).

### Person avatar (initials)
`grid place-items-center h-9 w-9 rounded-full text-xs font-semibold` with a soft color
pair (e.g. `bg-sky-100 text-sky-700`). **People only — never for status.**

### Names
User names render **without honorific prefixes** (Mrs./Mr./…), first + last only, on
**every page**. Use `display_person(user)` (new UI) or `formatted_name(name)` (existing `.display_name`
call sites) for the name, and `avatar_initials` for initials (all backed by
`NamePresentation`). This is presentation-only — the
stored `display_name` is never mutated (it must round-trip raw input for security).

A person's name is **identifying text, not a nav link**: render it `font-medium
text-slate-800` (dark), the same whether or not it is clickable, so it reads as a name rather
than a generic hyperlink. When it does link to that person's record, keep it dark with
`hover:text-brand-700 hover:underline` (distinct from the brand record-nav links used for a
case number or court date). Prefer not to send the user out of the current flow via a name;
if a name must link away, its destination needs a clear path back (an unmigrated edit page
with no return is a flow trap).

### Tag
"mine" etc.: `rounded bg-brand-50 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-brand-600`.

### Empty states (3 patterns)
1. **Cold start** (no data yet): centered icon tile + heading + one-line explainer +
   primary/secondary CTAs. Never show all-zero stat cards.
2. **Success / all caught up**: positive confirmation panel
   (`border-emerald-100 bg-emerald-50/40`, check icon) instead of a blank section.
3. **No results** (filters/search): centered search icon + message tied to the active
   filters + a "Clear filters" action.

### Form errors
Two layers, both design-system-styled:
- **Field level.** An invalid input / select / textarea shows a rose border. Rails wraps
  invalid fields in `.field_with_errors`, so `tailwind.css` colors those `border-rose-500`
  (`#f43f5e`, 3.67:1 against white, AA for a UI border) on casa_app. No per-field markup.
- **Summary.** A single-line `role="alert"` card above the form:
  `rounded-xl border border-rose-200 bg-rose-50 p-4` with a rose danger **icon tile** and one
  sentence, **"Unable to save:"** followed by the messages joined with `to_sentence` (no
  bulleted list). Use the `shared/_form_errors` partial on Tailwind pages; the legacy
  `shared/_error_messages` stays for Bootstrap pages.

### Dropdown / popover
Menus (the header account menu, the cases-page "More" actions menu) are a native
`<details>/<summary>` disclosure: the `<summary>` is the trigger (styled as a button,
`[&::-webkit-details-marker]:hidden`), the panel an `absolute right-0 z-20 mt-2 w-56
rounded-xl border border-slate-200 bg-white py-1 shadow-lg` card of links. The `dropdown`
Stimulus controller enhances it — native toggle plus close on outside-click and Escape
(focus returns to the summary) — and degrades to the plain native toggle without JS. Keep
menus a disclosure-of-links (not a full ARIA `menu` widget) unless a screen needs arrow-key
roving. (Distinct from `disclosure`, which is for inline panels like the edit-profile forms
that should stay open.)

The `<summary>` wears `button_classes(:secondary)` so the trigger matches the primary CTA's
40px height. Menu items are `flex items-start gap-2 px-4 py-2 text-sm`: the leading icon is
**top-aligned to the first line** (`items-start`), never centered, so a label that wraps
still reads with its icon (see Iconography). A form-driven modal can be a menu item by
rendering `Dialog::GroupComponent(wrapper_class: "contents")` so its trigger and dialog sit
directly in the menu.

**Header action pattern.** A page header shows **one primary CTA plus a `More` overflow
disclosure**, not a flat row of equal buttons. Keep frequently-used, core actions visible and
overflow only the occasional ones: the cases index overflows admin navigation (Case Groups,
Bulk Court Date); the case show keeps New Case Contact and Edit visible and overflows
Generate Court Report, Emancipation, and New Fund Request. Do not bury a core action in `More`, it
is both a UX cost (an extra click on a common action) and a testability cost (rack_test
cannot open a native `<details>`, so non-JS specs that click it break).

On **mobile**, collapse the remaining visible secondaries into `More` too, so only the primary
CTA and `More` share the top line. Render such an action twice with responsive visibility: a
button wrapped in `hidden sm:contents` (shown `sm+`) and a `sm:hidden` menu item (shown on
mobile). This keeps it no-JS and unambiguous, and a non-JS click still finds the visible
button (rack_test ignores the `hidden` class but respects the closed `<details>`).

### Disclosure (collapsible panel)
Secondary actions (e.g. Change Password / Change Email) hide behind a full-width trigger
button; the `disclosure` Stimulus controller toggles a `hidden` panel and keeps
`aria-expanded` in sync. Keep the trigger a real `<button>` so it stays keyboard- and
test-reachable.

### Modal (native dialog)
Built on the native `<dialog>` element driven by the `modal` Stimulus controller: `open`
calls `showModal()` (focus-trapping, Escape-to-close, and an inert background for free),
`close` closes it, a backdrop click closes it, and an `openOnConnect` value auto-opens on
load (e.g. the case-show thank-you dialog on the `?success` redirect). Tailwind's reset zeroes
the UA centering margin, so `tailwind.css` re-centers `dialog[data-modal-target="dialog"]`
(fixed, horizontally centered, `top: 24vh`, and `18vh` under 640px).

**One template for every task/confirm modal.** Panel: `w-[calc(100vw-2rem)] max-w-md
overflow-hidden rounded-2xl p-0 shadow-xl backdrop:bg-slate-900/40`, then three regions:
1. **Header** `flex items-center gap-3 border-b border-slate-100 px-5 py-4`: an optional 32px
   status badge, the `<h2>` title (`flex-1`), then a 32px close button (`bi-x-lg`,
   `text-slate-500`, `aria-label="Close"`).
2. **Body** `px-5 py-4`.
3. **Footer** `flex items-center justify-end gap-2 border-t border-slate-100 px-5 py-4`:
   `button_classes(:secondary)` (Cancel) then the primary or `:danger` action, right-aligned.

The template is the **`Dialog::` ViewComponent suite**: `Dialog::GroupComponent` (the
<dialog> shell plus the trigger slot, size, aria label, and controller wiring) composed with
`Dialog::HeaderComponent`, `Dialog::BodyComponent`, and `Dialog::FooterComponent`. Compose
those (they work even inside a `form_with`) so the three regions cannot drift. This is the
native-dialog replacement for the Bootstrap `Modal::*` suite.

Shipped instances: the court-report generator (form modal; submit posts via the
`court-report` controller) and `shared/_confirm_button` (destructive confirm; the danger
action posts via `button_to`, and the trigger, title, message, and labels are locals). A
confirm can also be opened **programmatically** by a Stimulus controller instead of a trigger
slot (the court-orders remove and copy-from-sibling, and the case-contact **topic-removal**
(`contact-topics`) and **additional-expense removal** (`casa-nested-form`) confirms — each replacing
a `window.confirm()`): wrap the `<dialog>` in `<div data-controller="modal"
class="contents">`, mark it `data-modal-target="dialog"` (for the centering rule) and a
target of the owning controller, call `showModal()` from that controller's action, and wire
the confirm button to the controller; Cancel / X / backdrop still use `modal#close`. A
separate **status variant** (the success/thank-you dialog) centers a 48px hero badge + title
+ single Close instead of a header bar. This replaces the legacy Bootstrap `Modal::*`
components on Tailwind pages; do not restyle Bootstrap `.modal` markup (its CSS is not loaded
on `casa_app`).

**Delete confirm in a table row.** For a per-row destructive confirm, reuse
`shared/_confirm_button` (a visible-label trigger + the Dialog). When a **non-`:js` (rack_test)**
spec drives the flow — click "Delete", assert the title, then a visible "Close"/"Confirm" — render
the Dialog directly with a **visible** "Close" button (rack_test can't match the header X's
`aria-label`, and `enable_aria_label` is off) and a `button_to` "Confirm" (the only element
rack_test actually submits; the trigger + Close are `type="button"` no-ops, and the whole dialog
sits in the DOM regardless of open state). The placements index is the reference — contrast the
checklist-item delete, a `button_to` + `turbo_confirm` for specs that click Delete and expect an
immediate submit with no in-page confirm text.

**Status badge token** (the modal icon): one shape, `rounded-full`, two sizes: **32px**
(`h-8 w-8`) inline in a header, **48px** (`h-12 w-12`) centered as a hero. Colored by intent
(`bg-rose-100 text-rose-600` destructive, `bg-emerald-50 text-emerald-600` success). This is
distinct from the stat/KPI **icon tile** (`rounded-xl`).

## App shell
- **Sidebar** (256px, `border-r border-slate-200 bg-white`): org **name only** in the
  header (no logo/brand mark — not a value-add at this size, and avoids image/variant
  infrastructure), then nav links (active = `bg-brand-50 text-brand-700`, idle =
  `text-slate-600 hover:bg-slate-100`). Nav visibility follows Pundit policies.
  Collapses to an off-canvas drawer below `lg`.
- **Top bar** (`border-b border-slate-200 bg-white/80 backdrop-blur`): mobile nav
  toggle, notifications, and the avatar **account menu** — the single place for identity
  + account actions (no duplicate identity block in the sidebar). Its header shows name,
  email, and a **role badge** — `current_role` as a soft pill colour-coded by role
  (Volunteer = sky, Supervisor = violet, Casa Admin = amber) — the single place the
  user's role is surfaced.
- **Content**: `bg-slate-50`, generous padding, cards. Org announcement banners render
  at the top of the content area (`layouts/_casa_banner`). Full org logo is reserved for
  contexts with room (sign-in, court reports / exports), not the shell.
- **Impersonation banner** (`layouts/_impersonation_banner`, above the top bar): when
  `current_user != true_user`, a full-width amber-400 bar (amber-950 ink, ~8:1) whose whole
  surface is the "stop impersonating" link. It carries a `.header` hook because the volunteer
  edit spec asserts the banner text `within(".header")` after impersonating lands on a
  casa_app page.
- **Flash strip parity**: each flash div carries a base `alert` class **plus** the flash key
  (`.notice` / `.alert` / ...) *and* the a11y `role` (`status`/`alert`). This mirrors the Bootstrap
  `_flash_messages` mapping (`flash_class` -> `"alert notice ..."`, so every flash box is an
  `.alert`), which lets both legacy hooks match on casa_app: `.notice` for the SweetAlert-notifier
  specs (e.g. a create that redirects to a migrated edit page), and `.alert` for the shared
  not-authorized redirect — that message is delivered as `flash[:notice]` (locked by ~dozens of
  request specs, so the key can't change), and only reads as an alert because the base class is
  always present. The classes are no-ops on Tailwind (styling is by role/type).
- **Stacking order (z-index).** The top bar is `relative z-[25]` so its account / notification
  dropdowns (absolute panels *inside* the header) always paint above page content. Relying on the
  header's `backdrop-blur` stacking context alone was fragile: any page element that makes its own
  stacking context (a positioned `z-*` toolbar, a `transform` / hover-lift card, a native control)
  ties the header and wins by DOM order — painting a page **button over the open dropdown**. The
  full order is **page content ≤ z-20 < top bar `z-[25]` < mobile nav scrim `z-30`** (so the open
  drawer still dims the header) **< sidebar drawer `z-40` < native `<dialog>` modals** (top layer).
  Keep page-content z-index ≤ 20; verify overlays with `elementFromPoint`, not by eye.

## Key patterns
- **Triage dashboard** (supervisor landing): greeting -> KPI row -> "Needs your
  attention" list -> roster table. Lead with what needs action; power tools live in a
  "More" menu.
- **Person edit page** (`volunteers#edit` is the reference): one `max-w-4xl` column of cards —
  back link, an identity header (honorific-free name + email, with **Impersonate** as a
  `:secondary` action and **no** top primary, since a fill-then-save page's primary Submit
  lives at the form bottom), then Profile (two-column field grid), Account (`dl` metadata
  grid), Status (activation controls), Cases (card list, not a wide table, in a narrow
  column), Supervisor, and Notes. Fields are editable vs read-only per `update_user_setting?`
  (the read-only branch omits the field id so the policy view-specs still pass). A person's
  supervisor renders as dark identifying text, not a link (a valid honorific-free name treatment;
  now that supervisors/edit is migrated too, linking it is an available polish rather than a flow
  trap). A destructive link that a `:js` spec drives with `accept_confirm`/`dismiss_confirm` keeps
  the **UJS `data: {confirm:}`** (native `window.confirm`), *not* the Dialog confirm — the Capybara
  confirm helpers can only operate a native confirm. **`supervisors#edit` follows this same shape**
  (Profile / Account / Status / Volunteers). The `manage_active` partial *name* is shared by both
  edit pages, so each role keeps its own Tailwind twin (`volunteers/_manage_active`,
  `supervisors/_manage_active`); likewise `supervisors/_manage_volunteers` is the casa_app twin of
  the shared Bootstrap `manage_volunteers`.

## Design decisions (rationale)

The *why* behind the system, so choices aren't re-litigated or lost.

- **Tailwind v4 runs alongside legacy Bootstrap, migrated page-by-page.** A big-bang
  rewrite is too risky for a volunteer-run app; each page is moved wholesale onto one
  system so the two CSS resets never collide. A page is "migrated" only when it renders
  on a Tailwind layout with no Bootstrap classes doing layout work.
- **Pages opt in to the new UI at the controller.** Render with `layout: "casa_app"`
  (in-app shell) or set `layout "casa_auth"` (split auth). The default
  `ApplicationController` layout stays the Bootstrap `application` layout, so untouched
  screens are unaffected. Set `@active_nav` to the sidebar key (e.g. `"volunteers"`) to
  light up the matching nav item. There is no global flag — the switch is
  per-controller-action and reversible.
- **Brand = indigo, neutrals = slate.** Calm, professional, high-contrast and
  accessible; visibly distinct from the old teal/lineicons look so progress is legible.
- **Figtree** as the typeface — a warm humanist sans that reads friendly but credible,
  and is free via Google Fonts.
- **Bootstrap Icons (`bi-*`), loaded by CDN — temporary.** They match the approved
  mockups and were fast to adopt, but MUST be vendored into the asset pipeline before
  production (tracked in `design-todo.md`). Font Awesome (`fas fa-*`) is **not** loaded
  on Tailwind pages — using it renders nothing. Use `bi-*`.
- **Icon tiles for status, initial-avatars for people — never mixed.** A soft colored
  rounded tile behind an icon means "a stat/status"; a colored initials circle means
  "a person". Keeping these disjoint avoids visual ambiguity.
- **Sidebar shows the org name only (no logo mark); identity lives in one top-bar
  account menu.** Dropping the logo avoids image/variant infrastructure that adds little
  at 256px, and consolidating identity removes the duplicate sidebar identity block. The
  full org logo is reserved for roomy contexts (sign-in, reports).
- **Honorific-free names are presentation-only.** Show first + last (no Mr./Mrs./…) on
  every page via `display_person` (new UI), `formatted_name` (legacy `.display_name`
  sites) and `avatar_initials`, all backed by `NamePresentation`. The stored
  `display_name` is **never** mutated — it must round-trip raw input for security.
- **Landing pages use the triage pattern.** Greeting -> KPI row -> "needs your attention"
  -> roster/table. Lead with what needs action, not vanity metrics; push power tools into
  a "More" menu. (See the supervisor dashboard for the reference implementation.)
- **Every screen designs its empty state** using one of the three patterns (cold-start /
  all-caught-up / no-results). Never ship all-zero stat cards or a blank section.
- **Accessibility is part of "done".** Skip link, `aria-current` on the active nav,
  `aria-label` on icon-only controls, visible `focus-visible` rings, `sr-only` table
  captions/labels, `role="status"`/`"alert"` on flashes, and `motion-reduce` on the
  drawer. The shell already meets this bar — keep new pages there.
- **Build:** `npm run build:tailwind` (minified) or `build:tailwind:dev` (watch, the `tw`
  process in `Procfile.dev`). Class names are discovered via the `@source` globs in
  `tailwind.css`. The output `app/assets/builds/tailwind.css` is **gitignored** and built
  on deploy — don't commit it.
- **Tables are bespoke, not jQuery DataTables (reversed).** Theming DataTables couldn't
  match the dashboard tables or meet WCAG — its generated chrome fights the design system.
  Build tables in Tailwind instead (matching the dashboard): server-side filtering +
  **Pagy** pagination + optional sortable header links, with **Turbo Drive** smoothing the
  GET navigations. Reuse each `*Datatable` class's query logic server-side; retire the
  DataTables JS as each page migrates. See the cases index for the reference pattern.

## Migrating a page (playbook)

Repeatable steps for moving one screen off Bootstrap:

1. **Read first** — this doc, plus the page's existing specs (know what behavior is
   pinned before you touch markup). Confirm each column / field you plan to keep still has a
   live data source; don't carry blank legacy columns forward (see Tables, above).
2. **Opt the action into a Tailwind layout** — `render ..., layout: "casa_app"` (or
   `layout "casa_auth"`), and set `@active_nav` when it maps to a sidebar item.
3. **Rebuild the view with the components above.** Wrap page content in
   `px-4 py-6 sm:px-6 lg:px-8`; use the h1/section-title scale; reuse the card, button,
   input, pill, KPI, and empty-state patterns instead of inventing new ones.
4. **Names:** `display_person` / `formatted_name` / `avatar_initials` — never raw
   `display_name`. **Icons:** `bi-*` only. **Status vs people:** icon tile vs avatar.
5. **Design the empty state** (pick the right one of the three).
6. **Keep behavior specs green.** When a spec is coupled to a presentational class, move
   it to a semantic hook (a `data-*` attribute) rather than weakening the assertion.
   Prefer system specs for new UI behavior (ADR 0006).
7. **Verify:** `npm run build:tailwind`, run the page's specs, then `bin/lint`. Confirm the
   page fits at true 375 / 414 / 768 / 1024 / 1280 widths, measured with a CDP device-metrics
   override (`bin/measure-responsive.mjs`) rather than `--window-size` (headless Chrome clamps its minimum
   window to ~500px, so `--window-size=375` silently measures 500).
8. **Checkpoint:** commit and push to `casadesign`, tick the item off in
   `design-todo.md`, and update the status below.

## Migration status

High-level progress; the granular, prioritized backlog lives in
[`design-todo.md`](design-todo.md).

- [x] Tailwind v4 foundation + design tokens
- [x] Typeface: Figtree
- [x] Auth pages (sign-in, forgot/reset password, invitation accept)
- [x] App shell — sidebar + top bar (`casa_app` layout)
- [x] Supervisor dashboard (triage-pattern reference)
- [x] Notifications
- [x] Edit profile
- [~] Other app-shell leaf pages (impersonation banner + flash parity shipped; help-link destination remains)
- [x] Volunteer dashboard (triage: cases, follow-ups, hours)
- [x] Admin dashboard (org triage: unassigned & stale cases)
- [x] Cases index (bespoke table + server-side filter selects + Pagy pagination)
- [x] Case workflows: cases index/show/new/edit + case contacts index + drafts + the multi-step
  **form** all shipped (filterrific kept, disclosure collapse; the form is an autosave Wicked
  wizard on casa_app). The opt-in `case_contacts_new_design` table is now a bespoke
  server-rendered casa_app table too (retired its jQuery serverSide DataTable; server-side filter
  scopes + ?sort= + Pagy; disclosure filter panel; expandable rows + inline row actions) — the case
  area is fully migrated.
- [x] Management (Phase 4): volunteers + supervisors index/edit, learning hours, case assignments,
  reimbursements, the reports hub, and **organization settings** all shipped (bespoke Tailwind
  tables + Pagy; reimbursements retired its serverSide DataTable; the reports hub keeps its
  `.report-form-submit` CSV-download JS + native `<select multiple>` filters; settings uses a
  `twilio` Stimulus controller that reveals the credential fields + toggles their required/disabled
  from the enable checkbox, replacing the jQuery + Bootstrap-collapse `src/casa_org.js`).
- [x] Court report generator (`case_court_reports#index`): a Dialog + the reused `court-report`
  controller, with a searchable single-select TomSelect case picker (the `searchable-select`
  controller) that preserves the select2 volunteer-name search.
- [x] Phase 5 admin CRUD long-tail (complete): judges/languages/placement-types/learning-hour-types+topics,
  contact types/groups/topics, hearing types + checklist items, custom org links, mileage rates,
  banners, placements, **court dates + bulk court dates** (shared court-order twin), **imports**
  (server-side link tabs + inline SMS-opt-in keeping src/import.js), and **emancipation** (checklist
  show keeps the src/case_emancipation.js AJAX/collapse hooks; index retires its DataTable). Banners
  brought `trix/dist/trix.css` into the casa_app tailwind bundle; placements/court-dates use
  Dialog / UJS deletes that satisfy non-`:js` specs.
- [x] Phase 6 (complete): the all-CASA-admin area on its own Tailwind shell (dashboard, casa_orgs,
  casa_admins, edit/new, patch notes — the jQuery clone-CRUD kept, its bundle + notifier wired in)
  + its auth pages on the casa_auth shell; and the public `static#index` landing page rebuilt on
  the brand palette (compiled tailwind, no CDN/Alpine). Regular-user Devise pages shipped in the
  foundation phase.
- [x] **Metrics & Analytics**: the platform activity charts were extracted from HealthController
  into a scope-parameterized `MetricsReport` and surfaced in two authenticated homes -- an all-CASA
  **Metrics** console (platform-wide, in the all_casa_admin sidebar) and a per-chapter **Analytics**
  page (org-scoped, admin+supervisor, with chapter KPI cards; beside Reports in the casa_app sidebar).
  Both share `metrics/_dashboard` + the `metric_*` helpers + the `chart-hover` controller (already in
  the app bundle). `/health` was slimmed to a minimal self-contained ops status page + deploy-time
  JSON, taking the cross-org charts off the public surface; the dead `metrics` JS bundle/layout and
  the unused legacy `/health` JSON graph endpoints were retired.

## Workflow
- On the `casadesign` branch: **commit and push at every checkpoint.**

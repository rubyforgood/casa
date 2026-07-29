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
- Build: `npm run build:css` (one-off) / `build:css:dev` (watch); the `tw`
  process in `Procfile.dev` runs the watcher. Output -> `app/assets/builds/`.
  The name `build:css` is required — `cssbundling-rails`' `css:build` task (hooked
  into `assets:precompile` on deploy) shells out to exactly that script.

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
  header block `mb-6` (24px); the header **row** is `flex flex-wrap items-{end|start} justify-between gap-3`: **`items-end`** for an **h1-only** header (the 40px CTA aligns to the h1 baseline) and **`items-start`** when the h1 carries a **subtitle** (CTA top-aligns to the title so the subtitle can't push it down -- measured, `items-end`+subtitle drops the 40px CTA ~16px too low to the subtitle baseline, which was the dashboards' bug: `ctaTop==h1Top` after the fix, matching reimbursements). h1-only volunteers/supervisors/cases use `items-end`; subtitle pages reimbursements/placements/banners/dashboards use `items-start`. a plain (borderless) filter bar gets `mb-4` so it sits **16px**
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
  button, which collapses its margin too). Pagination is the `shared/_pagination` **footer rendered INSIDE the table card** (its last child) -- a
  compact `border-t` + `px-4` + `py-3`, the industry-standard table footer (like learning-hours). On
  responsive pages whose desktop card is `hidden md:block`, ALSO render a `md:hidden` copy below the
  mobile card list. Never a detached below-card bar -- an external `mt-4` gap + divider + padding reads
  as too much scroll. Verify these gaps at the pixel level (filter-bottom -> table-top), not
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

**Measured token contrast on white** (computed from the built oklch tokens and cross-checked
against axe's own numbers — do not eyeball these, and do not assume a `-600` is safe):

| token | ratio | text (4.5:1) | icon/border (3:1) |
|---|---|---|---|
| `slate-400` | 2.63:1 | no | no |
| `slate-500` | 4.77:1 | yes | yes |
| `amber-600` | 3.19:1 | **no** | yes |
| `amber-700` | 5.05:1 | yes | yes |
| `emerald-600` | 3.67:1 | **no** | yes |
| `emerald-700` | 5.37:1 | yes | yes |
| `rose-600` | 4.51:1 | yes (barely) | yes |
| `rose-700` | 6.06:1 | yes | yes |

So `emerald-600`/`amber-600` are fine on a **decorative `aria-hidden` icon** but fail as
**text**: use `-700` for any status word ("Active", "+3 vs last month"). Watch the mixed
pattern `<span class="text-emerald-600"><i …></i> Active</span>` — the span colours the word
too, so it is text, not an icon. Keep a +/- pair on the same step so the two read at the
same weight.

**Heading order** (axe `heading-order`, and one `h1` per page above):
- A **subtitle/caption under the page `h1` is a `<p>`**, never a small heading. An `<h6>`
  used for "Case number: X" or "Create a court date for all cases in a group." skips h2–h5
  and fails. Small-and-grey is a type decision (`text-sm text-slate-500`), not a level.
- A **`<dt>` is already the term** — never nest a heading inside it. `<dt><h6>Judge:</h6></dt>`
  both skipped levels and doubled the semantics.
- A **card partial shared by a grouped index and a flat list needs a caller-controlled
  level**. `case_contacts/_case_contact` takes `heading_level` (default 3): `#index` nests
  cards under an `<h2>` case-number section, `#drafts` has no grouping level and passes 2.

**A `<label for>` does not name a custom element.** `label`/`for` only associates with
form-associated elements, so `<trix-editor role="textbox">` (and any custom element with an
ARIA input role) is left nameless — axe `aria-input-field-name` — even with a perfectly
correct visible `<label>` next to it. Set `aria: {label: …}` on the element itself. Same
remedy where a real `<label for>` would be actively wrong: the emancipation checklist inputs
are driven by JS that sets checked state after an AJAX save, so associating a label would
toggle natively on top of it — they carry `aria-label` and keep the label unassociated.

**Links inside a text block need more than colour.** `brand-600` on `slate-900` body text is
2.83:1 (3:1 required), so a case-number link inside an `<h1>`/paragraph gets `underline
underline-offset-2` (axe `link-in-text-block`).

**Scrollable regions must be keyboard-reachable.** Trix ships
`.trix-button-row { flex-wrap: nowrap; overflow-x: auto }`, a scroll container that is not
focusable (axe `scrollable-region-focusable`). `tailwind.css` overrides it to wrap instead.

**Auditing caveat:** axe only sees the **rendered** DOM, so a page with an empty collection
audits clean and hides real defects — a first whole-app pass missed unlabelled emancipation
checkboxes and both org-settings status chips purely because no categories/contact topics
were seeded. Seed at least one row of every repeating region before believing a clean result.
Likewise, a page that 500s reports `document-title` + `html-has-lang` + `landmark-one-main` +
`region`: that combination means you are auditing a layout-less Rails error page, not a
finding. Capybara then re-raises the server error on the *next* `visit`, so the exception is
reported against the following page.

**Audit at more than one viewport.** axe skips hidden elements, so a desktop-only pass cannot
see `md:hidden` / `lg:hidden` markup *at all* — and this codebase renders a separate mobile
card list next to every desktop table. A whole-app sweep run at 1400px came back clean while
390px still had six violations, every one of them in below-the-breakpoint markup:
- the auth pages' only `<h1>` sat in an `<aside class="hidden … lg:flex">`, so below `lg` the
  page had **no `h1` at all**. Fixed by making each form heading ("Welcome back", "Reset your
  password") the `<h1>` and the marketing line a `<p>` — the page's subject is the form, not
  the brand statement. Sign-in/reset/invite/confirm all follow this.
- the `lg:hidden` org-settings group labels were `slate-400`.
- the metrics data tables and heatmap become **scroll containers** once they stop fitting, and
  they contain no links or controls, so nothing inside could take focus (axe
  `scrollable-region-focusable`). A scrollable region built from pure data needs
  **`tabindex: 0`** on the scroll container itself so it can be scrolled from the keyboard.

**Icon contrast is not automatable — check it by hand.** axe has **no rule** for non-text
contrast, so a decorative-looking icon can fail 1.4.11 (3:1) on a page that audits perfectly
clean. The org announcement banner shipped its megaphone as `text-amber-500`, which is
**2.07:1 on the `amber-50` banner background**. Icons in an alert/banner should **inherit the
container's text colour** (as `shared/_flashes` does) rather than setting their own, which keeps
them at the same ratio as the copy they sit with. Note contrast is against the *tinted* surface,
not white: measure against the actual background.

**Flash messages** (`shared/_flashes`): success auto-hides, errors stay.
- A success message carries the `auto-dismiss` controller and clears itself after ~6s. The timer
  **pauses on hover and on `focusin`**, so it cannot vanish mid-read — that plus a delay well
  above a couple of seconds is what keeps an auto-hiding status message clear of WCAG 2.2.1. The
  message keeps `role="status"`, so it is announced when it appears; removing it later is silent.
- Warnings and errors (`role="alert"`) are **never** auto-dismissed: they are often the only
  record of what went wrong.
- The fade is applied as an **inline style**, not a utility class, and the removal is on a timer
  rather than `transitionend`. A class added from JS only works while Tailwind still emits it, and
  a missed `transitionend` would leave the message on screen forever.
- Because the partial keys off the flash type (`notice` -> green success, anything else -> amber
  warning), **an error must not be sent as `flash[:notice]`**, or it renders green *and* now
  auto-dismisses. Authorization failures use `flash[:alert]`: `ApplicationController#not_authorized`
  plus the cross-org `RecordNotFound` rescues in `CasaCasesController` and `CourtDatesController`.

Sweep at **390 / 768 / 1400** before calling a page clean. Also note a route-walking audit
silently skips **Flipper-gated** pages (it just follows the redirect): `/case_contacts/new_design`
was missed that way and had two failing status colours behind the flag.

## Components

### Buttons
Use the **`button_classes(:variant)`** helper (`DesignSystemHelper`) as the single source of
truth. Never hand-write button class strings in views; they drift (that is how the variants
ended up mismatched). Variants:
- `:primary` (filled brand): `bg-brand-600 text-white font-semibold hover:bg-brand-700`
- `:secondary` (outlined): `border border-slate-200 bg-white text-slate-700 font-medium hover:bg-slate-50`
- `:danger` (filled rose): `bg-rose-600 text-white font-semibold hover:bg-rose-700`
- `:danger_outline` (a **quiet outlined destructive** button): identical to `:secondary` at rest -- `border border-slate-200 bg-white text-slate-700 font-medium` -- and turns rose only on hover (`hover:border-rose-300 hover:bg-rose-50 hover:text-rose-700`, rose focus ring). Use it for a destructive action that sits **among bordered buttons** (a toolbar/section/header of `:secondary`/`:primary`), so it matches them at rest with no always-on red; use `ghost_class(:danger)` when the neighbours are ghost (see below). No red-at-rest either way.
- `:success` (filled emerald, for a **prominent** positive action, e.g. reactivating a deactivated user): `bg-emerald-700 text-white font-semibold hover:bg-emerald-800` (emerald-700, not 600: white on 600 is 3.77:1, below AA). A **repeated per-row/card "resolve"** (e.g. resolving a followup reminder) recedes to `:secondary` -- a filled emerald over-emphasizes a low-frequency action next to its neutral row-mates.

Every variant shares a base of `inline-flex h-10 items-center justify-center gap-2 rounded-lg
px-4 text-sm shadow-sm` plus a `focus-visible` brand ring and `disabled:` states. The fixed
**`h-10` (40px) height token** is deliberate: with `box-sizing: border-box` it absorbs the
outlined variant's 1px border, so filled and outlined buttons are the same height by
construction (40px is the mainstream medium-button height: Material 3, Chakra, shadcn). **Do
not** re-equalize sizes with `border border-transparent` on the filled variants; that is a
fragile compensation pinned to the secondary's exact border width, and the height token
already handles it.

**One primary CTA per page.** A view gets exactly ONE filled `:primary` button -- the page's main
action (on a form page, its save: "Submit" / "Save changes"). Every *other* action is lower emphasis:
`:secondary` for a clear standalone action, ghost for repeated row/toolbar actions. In particular an
inline **"assign a new X" / "add note" sub-form submit** inside a management card (Assign case / Assign
supervisor / Assign volunteer / Save note) is **`:secondary`, never `:primary`** -- it sits next to a
full-height select/textarea (so a 40px `:secondary` aligns with the input) and must not compete with
the page's save. Stacking a main-form Submit primary with several assign-form primaries is the
recurring bug -- it read as 3-4 competing CTAs on the volunteer / supervisor / case edit pages. A
**dialog keeps its own primary confirm** ("Yes, send reminder" / "Yes, copy"): that's the dialog's
local primary, visible only while the modal is open, so it doesn't count against the page.

**Left-aligning / splitting button content.** `button_classes` bakes in `justify-center`, and in
Tailwind v4 appending `justify-start` / `justify-between` does **not** reliably override it (utility
cascade order -- measured: label stayed centered). To left-align a label, or split it (label left,
trailing icon hard right) inside a `button_classes` button, wrap the label in a **`flex-1`** span: it
fills the free space, so `justify-center` has nothing left to center. The reports one-click exports use
this -- a leading report icon + label in a `flex-1` span, `bi-download` on the right (verified 17px
label/icon insets, not centered). Keep every child `pointer-events-none` if a click handler reads
`event.target` as the button (as `src/reports.js` does).

**Concise CTA labels.** A button label is the *action*, not a restatement of context the page already
supplies -- drop the page title and the file format. The Court reports page's primary CTA is
**"Generate report"** (the h1 + card already say "court report" and ".docx"; the Word icon signals the
format), not "Download court report as a .docx". Bonus: that trigger opens a config dialog, so
"Download" was also inaccurate -- the download happens after "Generate". If the trigger and the dialog's
confirm would collide (both "Generate report"), the dialog's `id` sits on the `<dialog>` so scoped
specs (`within "#modal-id"`) still hit the confirm, and the trigger keeps a fuller dialog title
("Generate court report").

**Feature-gated action** (an action that needs an org setting, e.g. "Send reactivation alert (SMS)"
which requires Twilio): keep it a **real, clickable button in both states** -- the *same*
`link_to`/element/variant as its enabled twin, only swapping in a struck icon (`bi-bell-slash`) and a
`title` tooltip stating the prerequisite ("Enable Twilio in your organization settings..."). Do **not**
render a `disabled` button: a disabled control sitting among live siblings reads as broken, gives no
feedback on click, and won't line up (a `disabled <button>` next to `link_to` `<a>` siblings landed
~4px low). Clicking when the feature is off is not a silent no-op -- the controller flashes its
"<feature> is disabled" notice, which is the feedback. The label is always the action, never the config
hint ("Enable Twilio to send reactivation alert (SMS)" both mislabels the action and buries the hint in
the toolbar). Because it's the same element in both states, the toolbar doesn't reflow when the setting
flips. The row itself is `flex flex-wrap items-center gap-2` so equal-height buttons align on one line.

**Assigned-entity rows** (a volunteer's cases / supervisor, a supervisor's volunteers): one row per
entity = **identifying label + inline status badges on the left, the Unassign/Remove action on the
right** (`flex items-center justify-between`), never the action stacked *below* the badges. The
standard "list item with a trailing action" (GitHub collaborators, Slack members): each entity reads
as one scannable line. The action matches its context per the destructive-button rule (here it sits
alone, so `:danger_outline`).

- Tertiary (ghost): the **`ghost_class(:neutral | :danger)`** helper (design_system_helper.rb) --
  `inline-flex items-center gap-1.5 rounded-lg px-2 py-1 text-sm font-medium text-slate-600`. **Both
  variants are slate at rest** (no jarring wall of colored text in a table); they differ ONLY on
  hover/focus: `:neutral` hovers gray (Edit / Detail view / View / Impersonate / Assign / filters),
  `:danger` hovers **rose** (every Delete / Remove / destructive action -- the destructive hover must
  be identical everywhere, never gray in one table and rose in another). Slate-at-rest + rose-on-hover
  is the **industry-standard destructive affordance** (GitHub, Gmail, Linear): it reveals danger at the
  point of action without an always-on red. Reinforced by the `bi-trash` icon + "Delete" label +
  confirm dialog. **A destructive action MATCHES the buttons beside it** (audit each context, never
  blanket one style): among ghost/compact actions (table rows, per-item lists) use `ghost_class(:danger)`;
  among **bordered** buttons (a toolbar/section/header of `:secondary`/`:primary`/`:success`) use
  `button_classes(:danger_outline)` (redefined above: slate at rest like `:secondary`, rose on hover) so
  it matches its neighbours at rest. Never mix a ghost destructive next to bordered buttons -- it reads
  as broken (a `casa_cases#show`-adjacent regression: a ghost Deactivate/Unassign next to `:secondary`
  Resend/Assign). Either way there is **no red-at-rest**. No border, fill, or shadow: the
  lowest-emphasis action, for repeated row / toolbar actions so they recede from brand links. It lives
  in a helper (not a `button_classes` variant -- it is a low-emphasis action at a shorter height, not a
  CTA) as the **single source of truth**, because copy-pasted inline strings drifted: case_groups sat
  at `px-2.5 py-1.5`, and the casa_org settings tables used bare `text-brand-600` / `text-rose-600`
  text links instead of the ghost. **Call the helper; never hand-write the string.** Neutral ink stays
  at or above AA (slate-600 is about 7:1; never `slate-400` under visible text). Leading icon via
  `gap-1.5` plus a `bi-*` glyph (`bi-pencil` Edit, `bi-trash` Delete). Right-aligned in a table's
  trailing actions cell, give that cell extra end padding (`pr-6`) so the control clears the card edge
  rather than skewing the button's own padding. **Every table row action is this ghost** -- Edit
  (`ghost_class`) / Delete (`ghost_class(:danger)`, passed as the confirm dialog's `trigger_class` with
  `trigger_icon: "bi bi-trash"` -- slate at rest, rose on hover) / Detail view / Impersonate / the per-court-date **Add to calendar** control (a `ghost_class` button whose `add-to-calendar` Stimulus controller builds and downloads an `.ics`, replacing the third-party `<add-to-calendar-button>` web component) AND a form-submit control like the
  volunteers-without-supervisors "Assign supervisor" button -- **never a
  `button_classes(:primary/:secondary)` CTA**: a filled CTA over-emphasizes a repeated per-row action
  and breaks table-to-table consistency. Right-align the whole trailing column (`text-right` cell +
  `flex items-center justify-end` when it holds more than one control, e.g. a `<select>` + Assign).

**Audit before shipping:** grep the views you touched for clickable elements (`link_to` /
`button_tag` / `button_to` / `<button` / `<a`) carrying a hand-rolled button shape
(`inline-flex` + `rounded-lg` + `px-`/`py-` + `bg-`/`border-`) and convert them to
`button_classes`. A bespoke string at `py-1.5` next to a 40px token is the recurring drift
bug; the only non-`button_classes` clickable is the tertiary ghost, which has its own `ghost_class`
helper (call it -- do not re-derive the string). **This grep is necessary but not sufficient:** a status glyph emitted by a Ruby **model/decorator/helper method** (e.g. a court order's ✅/❌ from an `implementation_status_symbol`) or a **third-party web component / legacy CSS-class widget** (e.g. `<add-to-calendar-button>` / `.cal-btn`) is not a class-string button, so the grep cannot see it -- also scan Ruby methods that emit glyphs and non-`button_classes` interactive widgets, and pixel-check the rendered page.

### Inputs
`block w-full rounded-lg border border-slate-300 px-3.5 py-2.5 text-slate-900 shadow-sm placeholder:text-slate-500 focus:border-brand-500 focus:ring-2 focus:ring-brand-500/30 focus:outline-none`

Placeholder ink is **`slate-500`**, like every other muted string -- `slate-400` is 2.63:1 and a
placeholder is text. All 50 placeholder sites in `app/` already use `slate-500`; this token was the
last `slate-400` placeholder left anywhere, and only in the doc.

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
The cases-index filter is the reference for the **chevron**, not for the padding above: a
*filter* control is one step more compact than a *form* field (see "Filter bar").

### Filter bar
Controls in a filter bar are **one step more compact than form fields** -- filters are
chrome above the data, not the primary task. Two sizes, both measured, don't mix them:

| | form field | filter control |
|---|---|---|
| select | `py-2.5 pl-3.5 pr-9` (42px) | `py-2 pl-3 pr-9` (**38px**) |
| text/date input | `px-3.5 py-2.5` (42px) | `px-3 py-2` (**38px**) |
| label | `mb-1.5 block text-sm font-medium text-slate-700` | `mb-1 block text-xs font-medium text-slate-500` (**12px slate-500**) |

Cases / volunteers / supervisors / reimbursements / case-contacts all converge on the filter
column; a filter built from the form tokens sits 4px taller with 14px slate-700 labels and
reads as a form embedded in the page (this was the case-contacts bug). Verify by measuring
control height against a sibling roster filter, not by reading tokens.

**Layout: one toolbar row, not a titled panel.** The list-toolbar standard (GitHub issues, Linear,
Jira, Notion, Polaris, Stripe) is a single horizontal row directly above the list, and the roster
bars follow it. Specifics, all measured on case-contacts:
- **No visible "Filters" heading.** The controls say what they are; a heading costs a whole row and
  reads as redundant next to a `More filters` trigger. Keep it as `<h2 class="sr-only">Filters</h2>`
  so the section stays named for AT and the heading outline survives. (Before: a 45px heading
  marooned **767px** from its trigger on a 960px card.)
- **A single high-traffic boolean goes inline in the row, beside the overflow trigger** -- not inside
  the panel. `Hide drafts` sits next to `More filters`. It also removes an alignment hack: in a row of
  *labelled* fields a bare checkbox has to fake a baseline (`pb-2.5`, measured 1px off); beside the
  trigger it just centres.
- **Bottom-aligning a bare control group against a labelled field lands it low.** The row is
  `items-end`, so a 28px action group bottom-aligns **5px below** the 38px control's centre. Give the
  group **`min-h-[38px]` + `items-center`** and the centres coincide. Verify by comparing centre-y of
  the sort control, the checkbox and the trigger -- `index_spec` "keeps Hide drafts on one line with
  the overflow trigger" asserts all three are equal.
- **Clear renders exactly when a FILTER is applied**, never at the defaults, where it is dead chrome
  (Polaris and Jira both gate it this way). `filters_applied?` is the predicate, and the awkward
  cases are why it exists: a checkbox always posts (`no_drafts=0` when unchecked) and array filters
  arrive as `[""]`, so neither can be judged by bare presence. It is a **ghost** action, not a 40px
  `:secondary`: as a bordered button it was the heaviest thing in the card, louder than the filters.
- **A sort is not a filter.** A non-default sort must not put a control labelled *Clear filters* on
  screen, and clearing must not silently reorder the list. So `clear_filters_path`, **not**
  `reset_filterrific_url` -- filterrific's reset drops the sort along with everything else. Both that
  link and every chip's remove link **always send a `filterrific` hash carrying `sorted_by`**:
  filterrific restores its *session-persisted* filters whenever the submitted hash is blank, so an
  empty one would hand the filters straight back. Case scope (`casa_case_id`) and panel state
  (`filters_open`) ride along too -- neither is a filter.
- **Do NOT gate Clear on the panel being open.** It is tempting (filters open the panel, so surely
  Clear belongs to the open panel) but it removes the escape hatch in the one state that needs it
  most: a filter applied while the panel is collapsed, where the user cannot see what is narrowing
  the list. Polaris / Jira / Linear / GitHub all keep the clear affordance independent of the
  popover's state.
- **No applied-filter chips here.** They were built and then removed. The count badge plus Clear is
  the treatment for this bar: the panel auto-opens when a hidden filter is active, so the filters are
  already on screen in the normal case, and chips duplicated that while doubling the surface that has
  to stay in sync. Chips remain the right pattern for a bar whose filters are *never* visible (Polaris
  / Linear / Jira), but that is not this one. If they ever come back, the × needs a **`title`** as well
  as an `aria-label` -- `aria-label` alone is invisible to Capybara's `click_on`, which matches
  text/title/id.
- **Never mix submit mechanisms on one filter bar.** This is what made the bar behave two ways at
  once. The legacy `.filter-input` inputs submit through a **jQuery** handler, which bypasses Turbo and
  does a **native full-page** submit; the multiselect's deferred submit used **`requestSubmit()`**,
  which fires a real submit event that Turbo intercepts and -- because the form carries
  `data-turbo-frame` -- scopes to the **results frame only**. Everything in the card lives *outside*
  that frame, so the Clear action and the count silently went stale after a contact-type change while
  every other control updated them. Use **`form.submit()`** (native) for the deferred submit so all of
  them agree. The trap when testing this: a frame update **preserves the document**, so tagging
  `window` and finding the tag still there proves nothing about whether a submit fired -- it only
  proves no *full* navigation happened. Assert on the chrome that must change (the count badge), not
  on document identity.

- **A sort control is labelled `Sort by`** (Jira / Polaris / Amazon; GitHub shortens to `Sort`), not
  Rails' auto-humanised `Sorted by`. It is **not** `Filter by` even though it sits in the filter card:
  it changes the order, not which rows show, so `Filter by` over a list of `(newest first)` /
  `(A-z)` orderings mislabels it. The card's own name is carried by the sr-only `Filters` heading.

**Same control, or same language?** "Pick contact types" appears three times and does not need one
control everywhere -- it needs one **grouping language**. The *filter* is a searchable multiselect
(chrome, must stay compact). `casa_cases` new/edit is the rich multiselect, now grouped to match. The
**case-contact form keeps its exposed grouped checkbox fieldset**: contact types is that page's
primary *required* input and each row carries a per-type recency hint ("2 days ago") that cannot
survive collapsing into chips, so forcing the filter's control there would cost real information on
the page where it matters most. What *is* unified is the **group label token** -- `text-xs
font-semibold uppercase tracking-wide text-slate-500` on the fieldset, the menu headers and the
sidebar alike. Consistency of the pattern, not of the widget.

**Past ~10 options, a filter is a searchable multiselect -- never an exposed checkbox grid.** The
case-contacts contact-type filter was ~25 checkboxes in ~10 groups: **502px** on desktop and **954px**
on mobile, i.e. **taller than the results list it filters**, so opening the panel pushed the data off
screen (the whole card hit 1599px on a 390px-wide phone). As one `multiple-select` TomSelect it is
**42px**, and the card drops to 415px desktop / 679px mobile. Groups become **`<optgroup>`s**, and the
chips are the "which ones are on" readout, so nothing is lost. Jira / Linear / GitHub / Polaris all
put long option sets behind a searchable control for the same reason. Keep `filter-input` on the
`<select>`: TomSelect's `change` is dispatched with `initEvent(name, true, false)`, so it **bubbles**
and the delegated auto-submit still fires (verify -- a non-bubbling change would silently make the
filter inert).

**`select_tag "name[]"` does not get the id you think.** Rails sanitises it to `name_` (trailing
underscore), so a `label_tag :name` pointing at `for="name"` matches **nothing** -- the control is
unlabelled, and the multiselect controller then finds no accessible name to copy, which is the
`select-name` violation again. Pass an explicit **`id:`**. (This was live on the prototype's Cases
filter.)

**Active-filter count: a tinted pill on the overflow trigger.**

```
[Sorted by ▾]        [☑ Hide drafts]  [Clear filters]  [More filters (2) ▾]
                                                                    ^^^
                                        brand-100 bg / brand-700 text, rounded-full,
                                        px-1.5 py-0.5 text-xs font-semibold
```

A **pill**, not a parenthetical in the label: a bare number inside the text reads as part of the
label and is easy to miss, where a tinted pill signals "something is on" at a glance (Jira, Notion,
Airtable all tint the control when filters are active). It **counts fields, not values** -- three
contact types picked is `1` -- and it **excludes the filters visible in the row** (sort, Hide drafts),
which would otherwise be double-reported. `hidden_filter_count` is the helper; it renders only when
positive, with an `sr-only` "N filters applied" beside it since the digit alone is not a sentence.
The richer version of this pattern is a **removable chip per active filter** (Polaris / Linear /
Jira), which says *which* filters rather than how many; the count is the cheap 90%.

**The unfiltered option is `All`** (`["All", ""]`, or `All <term>` -- `All volunteers`,
`All supervisors` -- when the field needs naming). Never `Display all`: it instructs the UI
instead of naming the scope, and it does not match any other filter on any other page. The
blank value means "no filter", which every filter scope must treat as a no-op
(`if value.present?`), so picking `All` genuinely clears that filter.

**`f.select` trap.** `f.select(method, choices, options, html_options)` -- `class:` belongs in
the **fourth** argument. Passing `{include_blank: "All", class: select_class}` as one hash puts
`class` in `options`, where Rails silently drops it: the select renders with **no class at all**,
so it is both unstyled *and* missing behavioural hooks (on case-contacts it lost `filter-input`,
the class the form auto-submits on, leaving three filters inert). Also pass the **current value**
to `options_from_collection_for_select(..., selected)`: when `choices` is pre-rendered option
HTML, `f.select` cannot mark the selection, so the control reads `All` while its filter is
active. `spec/system/case_contacts/index_spec.rb` "other filters" guards all three.

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
  default-select everything.) The **basic** `multiple-select` controller takes an optional
  **`data-multiple-select-placeholder-value`** -- use the **`Select or search <term>`** phrasing
  (matching the rich component; e.g. the report filters, one per line), **never `All <term>`**:
  `All supervisors` read as a *selectable option* users tried to pick, not an empty-state prompt.
  If a blank filter means "include everything", say so in **hint text under the group's subheader**
  (e.g. a "Filters" heading), not in the placeholder and **not floating between two field groups** --
  a hint sandwiched between groups is ambiguous about which group it modifies. When a placeholder is set the controller also passes **`hidePlaceholder: true`**, so the
  prompt disappears once a chip is present (a placeholder lingering next to selected chips reads as
  unfinished -- verify by selecting an item and checking the input's `placeholder` attribute is empty).
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
- **Clear-all inside the field, always visible once there is something to clear.** `remove_button`
  alone gives only a per-chip ×, which is a chip-at-a-time chore, so **both** controller paths
  (`createBasicMultiSelect` and `createMultiSelectWithOptionGroups`) also load
  **`clear_button: { title: 'Clear all selections' }`**, matching the searchable single-select.
  **The plugin's own CSS is the catch:** it ships the × at `opacity: 0` and reveals it only on
  `:hover` / `.focus`, so a control full of chips shows no way to empty it -- undiscoverable with a
  mouse and unreachable by hover on touch, and it leaves a `tabindex=0` control at zero opacity. So
  `tailwind.css` forces `.ts-wrapper.multi.plugin-clear_button.has-items .clear-button { opacity: 1 }`
  and hides the chevron unconditionally at `.multi.has-items` (they share the right edge).
  **Single-select keeps** tom-select's hover/focus reveal -- there the × *replaces* the chevron.
  Ink is **slate-500** (4.76:1; the theme's old slate-400 was 2.56:1, under the 3:1 icon floor), the
  hit area is forced to **1.5rem square** (tom-select's × measures 23×22, just under the 24×24 target
  minimum), and it gets a `:focus-visible` ring since it is `role=button tabindex=0`. Assert with
  Capybara `find(".clear-button")`, which matches only a **visible** element -- that is what catches a
  re-gated reveal. **Audited: all 10 instances** carry it (case-contacts index + new_design ×2,
  reports ×4, case groups, and the rich component on the case-contact form).
- **Menu group headers are a header, not a short option.** tom-select ships `.optgroup-header` at the
  options' own **13px/400** with **4px LESS left padding**, so a dark line sat one notch out from the
  items and read as misaligned text rather than a group label. Theme it with the **same token as the
  sidebar group labels** -- `12px`, `600`, `uppercase`, `0.025em` tracking, **slate-500** -- padded to
  the options' `0.75rem` so the left column edge is straight, plus a `slate-100` top border between
  groups. Verify by comparing the header's and an option's computed `paddingLeft` and `fontWeight`,
  not by eye.
- **A grouped multiselect must actually be told to group.** `optgroupField` alone is not enough:
  without **`optgroups:`** (the list of groups) TomSelect uses the option's `group` for **search only**
  and renders a flat list. The rich component carried `group` on every option and still showed 25
  ungrouped rows, while the filter's grouped `<optgroup>` markup showed headers -- the same data, two
  different menus. Pass `optgroups` + `optgroupField: 'group'` + `lockOptgroupOrder: true`.
  **Then audit every option builder that sets `group`.** While groups were search-only, a `group` that
  was not a human label went unnoticed; the moment they render, it is drawn as a header.
  `CasaCaseDecorator#hash_for_multi_select` set `group: casa_org_id`, so the relevant-cases dropdown
  grew a stray, unclickable **org id** above the cases. Cases are already org-scoped, so they carry no
  group at all now; contact types keep theirs because it is a real name.
- **Never re-render the page on each pick.** A multiselect wired to the `filter-input` change-submit
  fired a **full page render per chip**, which tore down the open menu: picking N types cost N page
  loads and N reopenings of the dropdown (confirmed by tagging `window` and watching the tag vanish).
  `closeAfterSelect` is a red herring -- it already defaults to false. Instead **leave `filter-input`
  off** and set **`data-multiple-select-submit-on-close-value="true"`**: the controller holds the
  submit while `select.isOpen` and fires it once on `dropdown_close`, so one menu session is one
  render. A change with the menu already shut (the clear-all ×) still submits immediately, so clearing
  stays instant. All the natural exits close the menu and apply the selection -- Escape, clicking
  another control, blur -- verified; note a Capybara click on a non-focusable element (an `h1`) does
  **not** close it, which will make a test look broken when the feature works.
- **Placeholder ink** in the tom-select theme is **slate-500**. Note
  `.ts-wrapper .ts-control input::placeholder` **outranks** a bare `.ts-control input::placeholder`,
  so set the colour in the `.ts-wrapper` rule only -- a second, lower rule silently loses (the theme
  carried both, and the slate-400 one won).
- **Flip-up**: the controller's `onDropdownOpen` adds `.ts-flip-up` when the control is near
  the viewport bottom, so the menu opens above and stays on screen.
- **Accessible name**: like the single-select, the controller sets an `aria-label` on TomSelect's
  control input from the native `<select>`'s name (its `aria-label` or associated `<label>`, read
  before init) **and stamps that name back onto the native `<select>` after init**. A `<label for>`
  picker (the report filters, case groups) is **not** already safe -- that was a wrong call here, and
  it cost the axe suite a critical `select-name` violation on the reports page: TomSelect repoints the
  label at its own input, so the label names the input and the `<select>` behind it ends up nameless.
  See "Searchable single-select -> Accessible name" for the full mechanism.
- Override tom-select at `.ts-wrapper.multi` specificity (and `!important` where it uses it);
  its default grey theme wins otherwise.

### Searchable single-select
For a single-select whose options are **unbounded / potentially long** (e.g. every active supervisor
in the org, on the "assign supervisor" per-row picker), use a **type-ahead**, not a native `<select>`:
the `searchable-select` Stimulus controller (TomSelect single-select). A native dropdown is fine only
for a short, fixed list (the 3-option status filter stays native). The supervisor/admin **volunteer
search** (the learning-hours roster and the other-duties log) uses this control as a *filter*
(`name="search"` + `auto-submit`) over a **Pagy-paginated table** -- the standard "review the time my
volunteers logged" shape; a per-person card/table stack (the old other-duties layout) doesn't scale
past a handful of people.
- **Width:** a standalone search/filter control is sized to **one form column** -- `sm:max-w-xs`
  (~320px) on the block `<form>`, so it's **full-width on mobile** (a two-column form's single column
  collapses to full width below `sm`) and one field wide on desktop. Applied uniformly on the
  learning-hours, other-duties, and emancipation searches; don't hand-pick `max-w-sm`/etc. per page.
  (Multi-field **filter bars** -- volunteers / cases / reimbursements -- are a separate responsive
  grid and set their own per-field widths.)
- **Inside an overflow container** (a table with `overflow-x-auto`, a card with `overflow-hidden`),
  pass **`data-searchable-select-dropdown-parent-value="body"`** so the menu renders on `<body>` and
  isn't clipped. Verify the open menu isn't clipped (it should sit just below/above the control).
- **Fallback class stays minimal** (`block w-full`): the theme owns the border/padding/shadow on
  `.ts-control`, and TomSelect copies the `<select>`'s classes onto `.ts-wrapper`, so a bordered class
  **double-borders** the control (measured: `.ts-control` 1px + `.ts-wrapper` 1px). Drop the manual
  chevron too -- the `.ts-wrapper::after` caret handles it.
- **Accessible name**: the controller sets an **`aria-label`** on TomSelect's control input, copied from
  the native `<select>`'s accessible name (its `aria-label`, or its associated `<label>` text, read
  *before* init). TomSelect wires a `<label for=...>` to its input via `aria-labelledby`, but **ignores
  an `aria-label` on the `<select>`** -- so a picker that labels itself that way (the roster / case /
  supervisor search filters) would otherwise render an input named only by its placeholder. Verify with
  the **accessibility tree** (the input's computed name is non-empty), not the mere presence of an
  attribute -- a `<label for>` picker (court report) already resolves to a name via `aria-labelledby`
  even with no `aria-label` on the input.
- **Name the NATIVE `<select>` too, after init.** Naming the control input is only half of it:
  TomSelect **repoints the `<label for=...>` at its own input**, which empties `select.labels` and
  leaves the original `<select>` with **no accessible name** -- and `.ts-hidden-accessible` *clips*
  that select rather than `display:none`-ing it, so it stays in the accessibility tree and trips
  axe's **`select-name` (critical)**. Both controllers stamp the pre-init name back on as an
  `aria-label` on the `<select>` itself. This is why a `<label for>` picker is **not** automatically
  safe: the label resolves for TomSelect's input, never for the select behind it. The symptom is
  slippery -- axe flags only the selects that have finished initialising, so the violation count
  moves between runs (the report filters showed 3 nodes one run and 2 the next).
- **Loads blank with an affordance**, never a pre-selected default: pass **`placeholder-value="Search …"`**
  (signals it's typeable AND is the empty state) plus a leading blank `<option value="">` (defaults the
  native `<select>` to empty for submit + no-JS). **A placeholder picker MUST also set
  `allowEmptyOption: false`** (the controller keys this off `placeholder-value`): otherwise TomSelect
  treats the blank option as a *selected item*, hides the input + its placeholder off-screen
  (`left:-10000px`) and shows an empty item -- the field then reads as blank with the caret pushed ~1/3
  in. With it false the empty option is neither an item (input stays on-screen showing the placeholder,
  caret right after the icon) nor a menu row.
- **Disable the submit until a choice is made** (it now loads blank): pass **`toggle-submit-value="true"`**
  -- the controller disables the closest form's `[type=submit]` until an option is picked and re-disables
  on clear. Add `disabled:opacity-50 disabled:cursor-not-allowed` to that button.
- **Clear (x)**: the `clear_button` plugin shows an x on focus/hover once a value is set. casa doesn't load
  the bundled bootstrap clear-button theme, so **hide the chevron while the x shows**
  (`.ts-wrapper.has-items.focus::after` / `:hover::after { opacity: 0 }`) -- the x sits where the chevron
  was, so they never overlap (idle: chevron shown, x hidden; focus/hover: x shown, chevron hidden).
- **Reads as a search field**: a leading **magnifier** (base64-SVG background) plus the slate-400
  placeholder makes it obviously a type-ahead. The magnifier is a **resting affordance only** -- scoped
  to `.ts-wrapper.single:not(.focus):not(.has-items) .ts-control` (+ `padding-left: 2rem`). The moment
  the user focuses (types) or a value is selected it's a plain field: **no icon, caret/text at the
  normal left** (`px-3.5` / 14px, matching the design-system text inputs). A persistent leading icon
  pushed the caret in on focus and lingered after a pick -- not standard type-ahead behavior.
  **Vertically center the content** (`align-items: center` on the single `.ts-control`; `align-self:
  center` on the item/input) -- otherwise the selected item stretches to the full content box and the
  text rides high (uneven top/bottom). Size the wrapper to fit icon + placeholder + insets (~`w-48`,
  192px), not wider.
- **One line, always** (single-select): `flex-wrap: nowrap` + input `min-width: 0 !important` + item
  `overflow:hidden; text-overflow:ellipsis; white-space:nowrap`. TomSelect's default input
  `min-width: 7rem` otherwise wraps a selected name + the input onto a 2nd line in a narrow field
  (growing the field's height), which also pushes the caret in -- abnormal for a single-select.

### Nested sub-form (repeatable rows)
The court-orders sub-form (`casa_cases/_court_orders` + `_court_order_fields`) is the
pattern: repeatable `.nested-form-wrapper` entry rows, an **Add** button that clones a
`<template>` (`court-order-form#add`), and a per-row **Delete** (`danger_outline`). Each row
is a full-width textarea + a one-column design-system status select + Delete, in a
`flex-col sm:flex-row` bordered card (`rounded-lg border p-3`). Copy-from-sibling is a
select + Copy button with a Dialog confirm (the `copy-court-orders` controller PATCHes
`copy_court_orders`, then reloads so the copied orders and the flash show).

### Autosave wizard form (case-contact)

**Bind the autosave on the FORM, never per field.** `data-action="input->autosave#save"` on the
`<form>`: `input` bubbles and fires for every control type -- text, number, date, select, checkbox,
radio -- so one action covers the whole form and cannot be forgotten when a field is added. Per-field
triggers produced a genuinely confusing form: only notes, topic answers and expense descriptions saved
themselves, so an edit to duration or medium was **silently dropped** when the user navigated away --
*unless* they also happened to touch one of those three, because an autosave posts the **entire** form
and therefore committed everything. Whether your work persisted depended on which field you touched
last. Measured before the fix: edit the duration, wait past the debounce, leave -> the old value; edit
the duration then type one character in notes -> both saved.

Because the form autosaves in full, it needs **no Cancel and no unsaved-changes warning** -- the two
coherent models are "everything autosaves" (Google Docs / Notion / Linear: navigation is the exit) and
"explicit save" (GitHub / Jira: Cancel plus a `beforeunload` + `turbo:before-visit` guard when dirty).
This form is the first. A partially-autosaving form is neither, and is the state to avoid.

**Testing an autosave: one interaction per example.** The "Saved!" alert lingers ~3s, so a second
interaction in the same example will match the PREVIOUS save's alert and let the assertion read the
database before its own 2s debounce has elapsed -- which reads as "checkboxes don't autosave" when they
do. Wait on the alert (`within "#contact-form-notes" { find 'small[role=alert]', text: "Saved!" }`),
then assert the record.
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

Required/optional field markers come from the `required_marker` / `optional_marker` helpers
(`design_system_helper`), **not** hand-written `.html_safe` string literals (erb_lint rejects those as
unsafe interpolation). `required_marker` is a rose `*` (`text-rose-600`, `aria-hidden` — the input's
`required` attribute carries the state to assistive tech); on a form that mixes required and optional
inputs, pair it with `optional_marker` (a muted "Optional", `text-xs font-normal text-slate-500`) on the
optional labels, so the split is explicit on every field rather than inferred from the lone `*`. This is
the app-wide convention for data-entry forms (see the forms-section bullet). Shared bits stay shared:
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
**Nested expense rows** are separated by a **divider** (`border-t border-slate-200 py-4`); the
fields **stack with visible labels** and are **full width** (amount, then description -- **both
required on submit**: a positive amount + a description, enforced only once the contact is being
submitted (`active_or_details?`) so the blank "Add another expense" row and draft autosaves are not
blocked. An incomplete or empty row blocks submit -- fill it in or **remove** it; a blank row is
never silently dropped (the volunteer may have just forgotten it)), with a small **"Remove" action**
(`.remove-expense-button`, the **destructive tertiary ghost** `ghost_class(:danger)` -- slate at rest, rose on hover; the old *always*-rose read as too jarring) on the amount label's line
(`flex justify-between`) — top-right, so it adds no extra row and doesn't narrow the fields (a side
icon narrowed them; a bottom ghost button added a row + whitespace; a grey `bg-slate-50` box read as
a nested card). **Space the two groups with `mt-4` on the description, NOT `space-y-4` on the row:**
the trailing hidden `id`/`_destroy` inputs make `space-y` put a bottom margin on the description
group, which doubled the gap down to the Add button (measured 48px). The **Add another expense**
button then sits at the row's own `py-4` (16px, no extra `mt`) — measure it, don't eyeball.
**Tailwind v4 `space-y-*` is zero-specificity** (`:where(& > :not(:last-child))`), so a child's own
`m-0`/`m-*` overrides it and collapses the gap. Reset a `<fieldset>`'s default inline margin with
`mx-0`, never `m-0`, inside a `space-y` stack -- `m-0` had silently removed the 24px gap after the
contact-medium / duration fieldsets (measured 0px). Likewise a **card root's own `mb-*` collapses a
card stack**: `_case_contact`'s leftover `mb-1` cut the index/drafts `space-y-4` gap from 16px to 4px
(pixel-measured) until removed -- a card in a `space-y` list carries **no** bottom margin; the stack
owns the gap (`.container-fluid` stays the inert spec hook, just without the margin).
Expenses are free-form (arbitrary count), so the notes check-to-add pattern doesn't apply. The wrapper keeps
`.nested-form-wrapper` + its data hooks. Deleting a **saved** expense goes through the design-system
confirm dialog (new/unsaved rows remove without a prompt).
**Case-contact form actions:** two submit buttons, not a mode checkbox — primary **Submit** (kept
first in the DOM so Enter submits it and `click_on "Submit"` (Capybara `:smart`) still hits it)
plus secondary **Submit & add another**, which carries `name="case_contact[metadata][create_another]"`
so `finish_editing` reopens a fresh form for the same case(s). Since there's no per-contact show
page, the create-another success flash gets a **trusted action link** via
`flash[:notice_action] = {"label", "path"}` — the casa_app flash partial renders it as a `link_to`
inside the notice (not raw HTML; the `:json` cookie serializer drops `html_safe`), pointing at
`case_contacts_path` so the user can find what they just created. Reusable for any notice.
**Structured mailing address:** captured as discrete parts (line 1 / line 2 / city / state / zip),
not one free-text field. `Address` keeps `content` as the canonical composed one-line string every
reader still uses (reimbursement table, mileage CSV, case-contact prefill): `Address.compose(...)`
plus a `before_save` that runs only when `structured?`, so legacy content-only rows and the factory
stay untouched. The reimbursement card reuses the same parts as five virtual attrs on `CaseContact`
that compose into the `volunteer_address` snapshot (`compose_volunteer_address`, skipped when all
parts are nil so the legacy single-string path — request specs, factory — still sets it directly;
a blank submit yields `""` so the reimbursement-wanted validation still fires). Prefill the fields
from the volunteer's structured Address (`decorate.volunteer_address_parts`) and give each a
`volunteerAddress` Stimulus target so `clearMileage` empties them all on uncheck. Layout (all three
structured-address forms): line 1 / line 2 full-width, then a `sm:grid-cols-6` row of city
(`col-span-3`, ½) · state (`col-span-2`, ⅓) · ZIP (`col-span-1`, ⅙) — state wider than ZIP because
a state name is longer; stacks full-width on mobile. Every part has a **visible label** (persistent —
not placeholder-only, since a placeholder vanishes on input); line 2 keeps an "Apartment, suite,
unit" placeholder hint. Miles driven sits in a **half-width** `sm:grid-cols-2` cell (aligns with the
details section's 2-col grid rhythm rather than an arbitrary max-width). The whole
case-contact form (details/notes/reimbursement/expenses) passes the axe (WCAG 2 A/AA) spec.

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
rounded-2xl` card (+ `pt-2` inset -- top only; a bottom inset would stack under an in-card pagination
footer and unbalance it, so use `pt-2`, not `py-2`, on a footered table card), full-bleed table, `thead th` = `text-xs font-semibold
text-slate-600` — **never an `uppercase`/`tracking-wide` transform** (column headers are sentence
case like every other label; an ALL-CAPS `text-slate-500` eyebrow header is a recurring drift — it
had crept into the reimbursements / settings / court-date / placements / all-CASA tables — converge
every `<th>` on this one token, matching what `sortable_header` emits). The `thead` itself is **unfilled** -- a `border-b border-slate-100` under the header row is the only separator, **never a `bg-slate-50` fill**, which clashes with the card's white `pt-2` inset and leaves a white strip above the grey header (a reimbursements-table drift). Header and body cells share the same `px-4 py-3` padding (so columns line up), and every `<th>`
is `align-top` — a column whose header wraps to two lines then anchors all headers to one top line
instead of vertically-centring the single-line neighbours (the browser `vertical-align: middle`
default, which reads as stray space). The **`sortable_header` sort caret** must likewise pin to the
header's *first line*: the header link is `inline-flex items-start` and the caret rides in a
one-line-tall `h-4 items-center` box (`sort_caret`). Plain `items-center` on the link re-centres the
caret on a *wrapped* label, so single- vs. two-line columns leave the row of carets jagged (measured:
the caret dropped 8px on wrapped headers at 1024px; after the fix every column's caret shares one
`svgTop` — verify by geometry, not by eye).

**Body cells, action buttons, and checkboxes all top-align to the row's first line -- never the
`vertical-align: middle` default** (which floats them centered whenever any cell in the row wraps to
two lines -- a recurring bug). Give every body `<td>` `align-top` (bake it into the shared `td` token)
**including the trailing actions cell**: a hardcoded action `<td>` (e.g. `px-4 py-3 text-right`) that
omits it leaves Edit/Delete floating centered while the data top-aligns -- the cases-index "button in
the wrong spot" bug, which had also drifted into the supervisors / casa_admins / other_duties /
org-settings / dashboard tables. A checkbox **alone** in a cell (bulk-select) gets the align-top cell
**plus `mt-0.5`** so its 16px box sits on the adjacent column's first text line (measured: checkbox
center == the name's first-line center, not just top==top). A checkbox **with its label in the same
cell** instead lives in `<label class="inline-flex items-center gap-2 whitespace-nowrap">`, which
self-aligns (no nudge) -- but keep that label **one line** (`whitespace-nowrap`): if the label text
wraps, `items-center` centers the box across both lines and the whole control drops ~10px below the
row's first line (the reimbursement queue "Mark complete" bug -- a checkbox-with-label cell is NOT
auto-safe; verify it too).
The **select-all header** is a *bare* checkbox (`aria-label` + `title` "Select all", `mt-0.5`) --
industry standard (Gmail/GitHub/Linear); never visible column-header text, which widens the narrow
column (put persistent bulk-action text in a toolbar above the table instead). Pixel-verify the
checkbox/button center against the first line, not computed style. `divide-y divide-slate-50`, `hover:bg-slate-50/70`.
Keep the `thead` even when empty and put an empty-state row in the `tbody`. Filtering /
sort / pagination are **server-side** (params + Pagy); the filter bar is plain selects that
submit on change (`auto-submit` controller). Pagination: render `shared/_pagination` as a **footer INSIDE the table card** (its last child) —
compact `border-t` + `px-4` + `py-3`, "Showing X–Y of Z" left, page controls right (`nav` +
`aria-label`, `aria-current`, `rel=prev/next`), preserving filter params — the industry-standard table
footer. On responsive pages whose desktop table card is `hidden md:block`, ALSO render a `md:hidden`
copy below the mobile card list (a card-list page like case-contacts renders it below the list). NOT a
detached below-card bar (external gap + divider + padding reads as too much scroll); verified in-card,
one visible nav, on learning-hours / reimbursements / volunteers / cases. **The card holding an
in-card footer uses `pt-2` (top inset only), NOT `py-2`:** a bottom card inset stacks under the
footer's `pb-3` and pushes the numbers closer to the divider than to the card edge; `pt-2` keeps the
footer symmetric (verified 13px above == 13px below the numbers). Don't render
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
permission-gated action. The card reminder **control** ("Set reminder" -> Dialog / "Resolve reminder" -> `:secondary`, never
filled `:success`) and the pending-follow-up **indicator** (an amber `alert_classes(:warning)` callout
with the note + who set it + when) are **shared partials** -- `case_contacts/_reminder_control` and
`case_contacts/_reminder_indicator` -- reused by the **case-show contact card** and the **case-contacts
index card**, so a reminder behaves identically everywhere (do not re-inline a per-page variant or a
SweetAlert prompt). The control renders **only for `active?` (finalized) contacts** -- a case contact stays a
draft with a nil `casa_case` until finalized, so a reminder on a draft would 500 on the redirect
(`casa_case_path(nil)`); it is gated at each card's render site. Creating or resolving one emails **both** the volunteer (the contact's creator)
and the setter via Noticed `deliver_by :email` -> `UserMailer`, gated on `receive_email_notifications`;
the new-design table keeps its own compact `:row`/`:bar` Dialog + bell indicator. Set/Resolve reminder and delete return via `redirect_back_or_to` /
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
- In progress / partial: `bg-amber-50 text-amber-700` + clock icon

Volunteer assignment reuses these three: Assigned (emerald), Unassigned (rose),
Deactivated volunteer (slate). Court-order implementation status uses the
`court_order_status_pill` helper (presentation lives in the helper, NOT the model):
Implemented (emerald + check), Partially implemented (amber + clock), Not implemented
(rose + x-circle), Not specified (slate + minus) -- **never OS emoji** (it replaced a
model `implementation_status_symbol` that returned literal ✅/🕗/❌, which render
inconsistently across platforms and are invisible to a class-string button audit). Court orders render as a compact 2-column **table** (`Court order` | `Status`, design.md table tokens: sentence-case `text-xs font-semibold text-slate-600` header, `align-top` cells, `divide-y`; pill in a left-aligned `whitespace-nowrap` status column). NOT a leading badge (variable widths make the directive text start at a ragged left edge) and NOT a right-floating badge (it hovers at the top-right of multi-line directive text) -- both were tried and read wrong; the directive text is a paragraph, so it needs a real column.

**A pill carries a status, never a quantity.** Counts belong in their own right-aligned numeric
column (`text-right` + **`tabular-nums`**), with the label in the column header and the cell
holding just the numeral. Every major system draws this line the same way -- Polaris badges,
Atlassian lozenges, Carbon tags are all for categorical state -- and GOV.UK and Material both
specify right alignment for numbers so digits line up and a column can be compared top to bottom.

The supervisor roster had three count pills stacked in one "Volunteers" cell
(`N attempting` / `N not attempting` / `N transition-aged`), the first two omitted at zero. Two
things went wrong, and they are what to watch for:
- **Ragged metrics.** Because the leading pills were conditional, the *same* metric landed at a
  different x-offset on every row -- measured 787 / 651 / 673px for `transition-aged` across three
  rows. Nothing could be scanned down the column. As columns, all four right-align exactly.
- **Omitting a zero breaks comparison.** Show `0` (muted `text-slate-500`), don't drop the cell;
  a missing number is not the same as zero, and dropping it is what made the row shift.
Counts are also **dead ends unless they link**: point each one at the filtered list where a filter
exists (`volunteers_path(supervisor:)`, `volunteers_path(supervisor:, transition: "yes")`). Colour
and weight stay as *reinforcement* only -- the header names the column, so nothing is colour-only.

**Every figure in a numeric column gets the SAME style -- one colour, one weight, zeros included.**
Use the table body colour (`text-slate-700`) + `tabular-nums` + `text-right` and vary nothing per
cell. This took three tries to get right, and each intermediate version looked reasonable in
isolation:
1. rose on the non-zero "needs follow-up" count. rose *is* that semantic token, but the system spends
   it on **status pills and danger buttons**, not bare coloured digits, where it makes colour carry
   the meaning and reads as an error state rather than a figure.
2. weight instead (`font-semibold` on the interesting one, muted `text-slate-500` for zeros) plus a
   brand-coloured link on the two figures that had somewhere to point.
That last combination put **four different treatments in four adjacent cells** -- colour meaning "is
a link", weight meaning "is the actionable one", muting meaning "is zero" -- three unrelated signals
fighting in the one place whose whole purpose is comparing figures down and across. A reader cannot
tell whether blue-vs-grey encodes magnitude, status, or navigability.

So: **no per-cell emphasis, and never put the drill-through on the numeral.** Where the row needs to
link somewhere, make it **one row-level action** in the actions column (`ghost_class`, alongside
Edit -- the two-ghost-action shape the cases table already uses). That also stops the styling from
advertising an asymmetry in the data model: only two of the roster's four counts could link at all,
because `volunteers#index` filters by supervisor and transition age but not by contact activity.
If a count genuinely needs a status treatment, that is a pill in its own status column -- in the
numeric column it would break the digit alignment the column exists for.

**A count that links needs `record_link_class`, and the destination needs a way back.** These are
record links in a links-only cell, so the brand colour is the cue: use
`"font-medium #{record_link_class}"` and **not** a hand-rolled string with a persistent underline
(that treatment is reserved for a record link sitting inline in body text, and hand-rolling it also
loses the helper's focus ring). Drilling from a roster into a filtered list is a **flow trap** unless
the destination offers a return -- the rule already stated under Names, and easy to miss because the
destination here (`volunteers#index`) is itself a top-level nav page, so it must show the back link
**only** when it was actually reached from somewhere:
- Mark the origin with `from:` on the drill-through link -- the app's existing convention
  (`volunteers/edit` already reads `from=other_duties` / `from_case_id`).
- Render the documented chevron only when `params[:from]` says so. A page with top-right actions uses
  the "title + actions" shape (back link + `h1 mt-2` as the left column), not `shared/_page_header`.
- **Carry the origin through anything that re-renders the page**: a filter bar submits only its own
  fields, so without a hidden `from` the back link vanishes the moment the user filters.
  `shared/_pagination` is already safe (it merges `request.query_parameters`).
- **Carry it one hop further**, onto the per-row links, or the next page returns to the *unfiltered*
  list and strands the user again. Verified end to end: roster -> filtered list -> volunteer -> back
  to the filtered list -> back to the roster, with the link absent when arriving from the nav.

**Trade-off to check when converting pills to columns:** wrapping pills fit a narrow viewport;
fixed columns do not. The roster table measured 341px (no scroll) as pills and 616px in a 341px
viewport as six columns, i.e. the change *introduced* horizontal scrolling on mobile. A data table
is the documented WCAG 1.4.10 Reflow exception and axe stays clean either way, so this will not show
up in an audit -- measure it. The fix is this page's existing pattern: desktop table
`hidden md:block` plus a `md:hidden` card list repeating the figures in a labelled `dl` grid. Hoist
the counts into one array first (`no_attempt_for_two_weeks` walks every volunteer's contacts, so
rendering both copies would double that), and keep ids and `[data-stat]` hooks on the table only so
the two copies never collide.

### Person avatar (initials)
`grid place-items-center h-9 w-9 rounded-full text-xs font-semibold` with a soft color
pair (e.g. `bg-sky-100 text-sky-700`). **People only — never for status.**

### Contact medium (card meta line)
A case contact's medium (in person / video / voice / text / letter) is **how** the contact happened --
a fact peer to date, duration, and miles. Show it as **plain text in the card meta line**
(`CaseContactDecorator#subheading`, e.g. "July 21, 2026 | In person | 30 minutes"), NOT as an icon.
An icon-only medium is a poor signifier: the glyphs are ambiguous (an envelope is text OR a letter?),
undiscoverable behind a hover, invisible on touch, and read as decoration -- reviewers couldn't tell
what it meant. Plain text beside the other facts is self-evident, needs no hover, and works everywhere;
`subheading` omits the medium when unset, like the other conditional facts. Both the index card
(`case_contacts/_case_contact`) and the case-show card (`casa_cases/_case_contact_card`) render
`subheading`, so they stay in sync. (History: this replaced a hover-tooltip icon badge. If a future
compact view really wants an at-a-glance glyph, pair the icon WITH its visible text label -- never
icon-alone -- and note that Tailwind v4 gates `hover:`/`group-hover:` behind `@media (hover: hover)`,
so a hover-only reveal silently fails on touch / hybrid-pointer devices.)
Medium names are **sentence case** ("Voice only", "Text/email") everywhere: `medium_label` and
`contact_mediums` (the medium dropdown / radios + the index filter) both derive it via
`medium_type.tr("-", " ").humanize`, so they don't drift back to Title Case.

### Names
User names render **without honorific prefixes** (Mrs./Mr./…), first + last only, on
**every page**. Use `display_person(user)` (new UI) or `formatted_name(name)` (existing `.display_name`
call sites) for the name, and `avatar_initials` for initials (all backed by
`NamePresentation`). This is presentation-only — the
stored `display_name` is never mutated (it must round-trip raw input for security).

A person's name is **identifying text, not a nav link**: render it `font-medium
text-slate-800` (dark), the same whether or not it is clickable, so it reads as a name rather
than a generic hyperlink. When it does link to that person's record, keep it dark but give it a
**persistent** underline (`underline underline-offset-2 hover:text-brand-700`, NOT `hover:underline`)
so it's discoverably clickable: a name that only underlines on hover reads as plain text and users
don't know to click it. The underline is a non-color cue (WCAG 1.4.1), slate-800 on white is 14.7:1
(1.4.3), + a focus ring (2.4.7). Use the **`name_link_class`** helper (callers prepend the font
size/weight, e.g. `"font-medium #{name_link_class}"`) so every clickable name matches app-wide. Dark +
underline stays distinct from the brand-colored **record links** (a case number or court date), which
use the counterpart **`record_link_class`** helper (brand-600 + hover underline + focus ring): the brand
color is the link cue in a links-only cell, so add a persistent `underline` only when a record link
sits inline within body text (brand-on-text is under 3:1, WCAG 1.4.1). The two helpers are the only
two in-content link treatments -- dark `name_link_class` for people, brand `record_link_class` for
records -- so links read consistently everywhere. Prefer not to send the user out of the current flow via a name;
if a name must link away, its destination needs a clear path back (an unmigrated edit page
with no return is a flow trap).

### Tag
"mine" etc.: `rounded bg-brand-50 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-brand-600`.

### Dashboard worklist ("Needs your attention")
A prioritised list of things to act on. **One container: the section card** -- and inside it, the
same desktop-table + `md:hidden`-divided-list pair the sibling tables on these pages already use
(`hidden overflow-x-auto md:block` table, then `divide-y divide-slate-100 md:hidden` rows).

**Pick table vs list by the row's width, not by taste.** A divided list is right in a narrow column
and wrong in a wide card: `justify-between` pins two small items to opposite edges, and at a ~918px
card that measured a **645px void** per row -- which reads as an empty table, the exact complaint the
tinted boxes had been hiding. Columns spend that width on data instead (largest inter-column gap after
the fix: 0px). So:
- **Wide card (a full-width dashboard section): a table.** Give it at least two data columns, or the
  same void reappears in table clothing -- the admin worklist only had a case number, so it gained a
  **Next court date** column, which is also what you triage on. Use the sibling table's tokens:
  `thead` `text-left text-xs font-semibold text-slate-500`, `th`/`td` `px-4 py-3`, `tbody`
  `divide-y divide-slate-50`, `tr` `hover:bg-slate-50/70`, `<caption class="sr-only">`, `scope="col"`.
- **Narrow column or below `md`: the divided list**, with the context on a second
  `text-xs text-slate-500` line.
If a new column needs data the service does not have, **batch it** -- `AdminDashboard` documents
"no per-case queries", so `next_court_dates` is one grouped `minimum(:date)` lookup, not
`CasaCase#next_court_date` per row (3 queries total for the section, verified).

Each row is primary text (a record link, or a person's name as identifying `font-medium
text-slate-800` + the initials avatar), and **one** action.

**Do not give each row its own box.** All three dashboards shipped every row as a rose-tinted,
rose-bordered `rounded-xl` panel with a filled 40px rose icon tile, nested inside the section card.
Two things go wrong and both get worse with length:
- **Card-in-card.** The section card is already the container; repeating it per row is the nested-card
  anti-pattern Material calls out for continuous lists. Measured at six rows: 6 boxes, 12 rose-tinted
  elements and 6 icon tiles, 528px tall vs 483px for the divided list.
- **A tint on every row signals nothing.** Alert fill is for a *single* message (one banner). Applied
  to a repeating collection it stops meaning "urgent" and just becomes the background, while fighting
  the card it sits in. State severity **once** -- the section heading plus its count.

**List or table?** A list when each row is "an entity + a little context + an action" (Polaris
ResourceList). A table only when rows carry several comparable attributes worth scanning or sorting
column-wise -- then use the numeric-column rules above. These worklists are the former.

**One action button per row.** The supervisor dashboard had *two adjacent ghost buttons with the
same href* -- "Send reminder" and "View", both the volunteer page. Two controls styled alike, sitting
side by side, doing the same thing. Keep the verb (deep-linking it to the page where the action lives
is fine and is what these dashboards do: "Assign a volunteer" -> the case page) and drop the second.

A record link in the row text *plus* one action button is **not** the same defect, even when both
resolve to the same page: they are different affordances in different positions, and the row reads
"here is the case / here is what to do". So the dashboards differ on purpose -- a case number is a
record link (`record_link_class`), while a person's name is identifying text
(`font-medium text-slate-800`), because design.md prefers not to route users out of a flow via a
name. Admin/volunteer rows therefore carry a record link + an action; supervisor rows carry a name +
an action.

The empty state keeps its single tinted panel -- that is one message, which is exactly what alert
fill is for.

### Empty states (3 patterns)
1. **Cold start** (no data yet): centered icon tile + heading + one-line explainer +
   primary/secondary CTAs. Never show all-zero stat cards.
2. **Success / all caught up**: positive confirmation panel
   (`border-emerald-100 bg-emerald-50/40`, check icon) instead of a blank section.
3. **No results** (filters/search): centered search icon + message tied to the active
   filters + a "Clear filters" action.

### Alerts, flashes & form errors
**One alert card for everything** — flash banners and the form-error summary share a single token
so they read as the same component, colored by severity. `alert_classes(:success | :warning |
:danger | :info)` (in `design_system_helper`, sibling of `button_classes`) returns the card
(`flex items-start gap-2.5 rounded-lg border px-4 py-3 text-sm` + a semantic border/bg/text) and
`alert_icon(variant)` the leading `bi-*` (check-circle / exclamation-triangle / info-circle). Full
class strings are written out so the Tailwind scanner compiles them. Colors follow the table
(emerald success, amber warning, rose danger, brand info).
- **Flash banners.** One partial, `shared/_flashes`, rendered by **every** layout (`casa_app`,
  `casa_auth`, `all_casa_admin`) via `render "shared/flashes", wrapper_class: <layout padding>` — no
  more per-layout copies that drift. `notice` → success, every other key → warning. Keeps the
  `alert` + `<type>` classes (`.notice` SweetAlert specs, `.alert` not-authorized redirect), the
  `header-flash` container (all-casa spec), the a11y `role`, and the `notice_action` trusted
  `{label, path}` link appended to a notice.
- **Field level.** Every invalid field shows a rose border **and** a visible message, so the error
  is never carried by color alone (WCAG 1.4.1). **This is automatic app-wide:** a global
  `field_error_proc` (`config/initializers/field_error_proc.rb`) wraps each invalid field (keeping the
  `.field_with_errors` rose border) and, for a text-like control (input / select / textarea; not
  radio / checkbox / hidden), adds `aria-invalid` + the secondary-gray message beneath it -- skipping
  any control that already has `aria-describedby` (placed by hand below), so nothing doubles, and new
  forms get it for free. For hand-placed cases (radio/checkbox groups, a composed fieldset, custom
  placement) `field_error(record, attr)` (in
  `design_system_helper`) renders a secondary-gray, sentence-case message (`text-slate-500`) with a centered rose
  `bi-exclamation-circle` icon right under the field;
  `field_error_attrs(record, attr)` splats `aria-invalid` + `aria-describedby` onto the input (or,
  via `tag.attributes(...)`, onto a radio/checkbox `<fieldset>`) so assistive tech ties the field to
  its message. The rose border comes from both `.field_with_errors` (Rails' auto-wrap) and
  `[aria-invalid="true"]` (`tailwind.css`, `#f43f5e`, 3.67:1 AA). Attribute errors show at the field;
  even cross-field rules flag at the field -- the reimbursement mileage / mailing-address checks add
  their error to a representative attribute (`:miles_driven` / `:volunteer_address`), not `:base`, so
  the field (or fieldset) is marked, not only the summary. When a case has several volunteers and the
  editor isn't one of them, the mailing address can't be inferred, so the form shows a **volunteer
  picker** (`reimbursement_volunteer_id`) above the address fields instead of disabling them; choosing
  one prefills + saves that volunteer's address (`case-contact-form#pickReimbursementVolunteer`). **Native HTML5
  validation is disabled app-wide** so this (and the summary) can show — otherwise the browser's native bubbles
  (`required`, `type`, `min`) fire first, block the submit, and can't be styled. A global handler in
  `application.js` sets `form.noValidate` on every form on load / `turbo:load` / `turbo:frame-load`
  (Turbo Drive is off, so it runs on each full page load); opt a form back in with
  `data-native-validation`. An invalid submit then reaches the server and re-renders the
  design-system errors. (The case-contact form also sets `novalidate` explicitly, server-rendered.)
- **Required / optional markers.** `required_marker` (rose `*`, aria-hidden) marks a required label and
  `optional_marker` (muted "Optional") marks an optional one on a form that mixes the two, so the split
  is explicit per field rather than inferred from the lone `*`. Which fields are required comes from the
  model validations (e.g. a `User` needs email + display name; phone / DOB / address are optional), not a
  guess. The required input also carries `required` (a11y; harmless because native validation is disabled
  app-wide, so it never pre-empts the server-rendered errors). Applied to the data-entry forms app-wide —
  volunteers / admins / supervisors profiles, casa_cases, court dates, and the settings CRUD forms. An
  edit form gated on `can_edit` **suppresses** the markers when the profile is read-only (nothing is
  editable, so they would be noise). Single-required-field forms (e.g. a settings name) just take the `*`.
- **Summary.** `shared/_form_errors` — the **same alert card** (`alert_classes(:danger)` + icon),
  `id="error_explanation"` + `role="alert"` + the `alert` class + the lead **"Unable to save"**
  (spec hooks). It lists **every** error so the summary matches the per-field messages: a lone error
  stays inline ("Unable to save: …"), several render as a `list-disc` list (no run-on `to_sentence`,
  no doubled punctuation). Pass `order:` (attributes in form order) so the list reads top-to-bottom
  like the page — unlisted attributes and `:base` fall to the end. It is the **only** error summary now — the legacy Bootstrap
  `shared/_error_messages` (bulleted `<ul>`) and the bridge `casa_admins/_errors` were deleted, their
  all-casa / casa-admin pages migrated onto `_form_errors`.
- **Message copy.** Validation messages are app-shipped copy: sentence case (fix the i18n attribute
  labels — e.g. `case_contact.case_contact_contact_types` is "Contact type", not "Contact Type") and
  **no trailing period** (a `:base` sentence like "Must enter miles driven…" ends without ".", so it
  reads cleanly as a list item and never doubles into "…reimbursement., and …").
- **Enabled + validate, not disabled-until-input.** A submit that would otherwise sit *disabled*
  until a field/select is filled instead stays **enabled**; an invalid submit is blocked client-side
  (`preventDefault` + `stopPropagation`) and shows an inline field-error (`bi-exclamation-circle` rose
  icon + slate-500 text, matching `field_error`, toggled with a `hidden` class) and focuses the field
  -- so the user can always click and learn why. Used by the CSV imports, the SMS opt-in "Continue",
  copy-court-orders, volunteers bulk-assign, and the supervisor-assign row. Disabling a button
  *during* submission (reports, court-report generate) is the correct, kept use of `disabled`. For a
  TomSelect field the guard must **not** call `.focus()` on failure -- that re-opens the dropdown over
  the error.

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
Secondary actions (e.g. Change password / Change email) hide behind a full-width trigger
button; the `disclosure` Stimulus controller toggles a `hidden` panel and keeps
`aria-expanded` in sync. Keep the trigger a real `<button>` so it stays keyboard- and
test-reachable.

**The trigger label names the CONTENT, never the action.** This is the WAI-ARIA APG disclosure
rule (the button's accessible name describes the content it controls; `aria-expanded` carries the
state) and it is what Material, USWDS, Polaris and Primer all ship. `Expand / Hide` named the
action twice, described nothing, and duplicated `aria-expanded` -- and the two case-contacts
filter panels had already drifted to different casings of it. So:

| trigger | label |
|---|---|
| filter panel, some filters visible outside it | **`More filters`** (card heading `Filters`) |
| filter panel controlling every filter | `Filters` |
| form section | the section name -- `Change password`, `Change email`, `Filter columns` |
| icon-only row expander | content name as `aria-label` -- **`Contact details`**, not `Toggle contact details` ("Toggle" duplicates `aria-expanded`) |

On case-contacts the sticky filters (Sorted by / Hide drafts / Reset filters) sit *above* the
panel, so a bare `Filters` on the trigger would misdescribe what it controls -- hence
`More filters`, the label Jira / Linear / Polaris use for exactly this split.

**State is `aria-expanded` + a chevron that rotates -- never the label text.** Put `group` on the
trigger and `transition-transform group-aria-[expanded=true]:rotate-180` on the chevron
(`group-open:rotate-180` inside a native `<details>`). **Tailwind v4 emits `rotate-180` as the
standalone `rotate` property**, so verify with `getComputedStyle(el).rotate` (`none` ->
`180deg`): `.transform` reads `none` in *both* states and will tell you a working rotation is
broken. Verified rotating: the case-contacts + new-design filter panels, users/edit change
password + change email, all-casa-admins change password, reports "Filter columns".

**A disclosure inside a form that re-renders must carry its open state across the render.** Otherwise
the server re-derives it and the panel snaps shut under the user. Two shapes of this, both were live:
- **Auto-submitting filter bar** (case-contacts index + new_design). The open state was
  `expand_filters?`, i.e. "is a hidden filter active", re-evaluated on every submit -- so the panel
  closed itself whenever a change left no hidden filter on: **clearing** the contact types, setting a
  select back to **All**, and even just ticking **Hide drafts** while the panel was open (the user had
  not touched a hidden filter at all). Fix: the `disclosure` controller takes an optional **`field`
  target** -- a `hidden_field_tag :filters_open` inside the form -- and writes `1`/`''` into it on
  toggle. The view reads `filters_open?`, which honours that param when present and falls back to
  `expand_filters?` only on first load (so a URL with filters still arrives open). Check **both
  directions**: a panel the user *closed* must stay closed even while a filter is active, which
  deriving-from-params also got wrong.
- **Validation re-render** (users/edit change password + change email, all-casa-admins change
  password). `update_password` / `update_email` fail with `render :edit`, and the panels hardcoded
  `hidden` + `aria-expanded="false"` -- so the error rendered at the top of the page while the form it
  referred to collapsed out of sight, losing the user's input. No round-trip needed here: **`action_name`
  is still the failed action** inside `render :edit`, so open exactly that panel
  (`password_open = action_name == "update_password"`) and leave its sibling shut.

Not affected: the reports column-filter `<details>` (its form native-submits a CSV download, so the
page never re-renders) and the new-design row expanders (a filter change legitimately re-runs the
query and resets rows).

**Deliberate exception:** the case-contact card's inline `<details>` swaps `Show details` /
`Hide details` via `group-open:`. That is an inline "more of this item" reveal, not a section
header, the text still names the content, and a state-swapping label there is well-precedented
(GOV.UK's accordion does it for every section). Keep it; don't propagate it to section triggers.

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

**`shared/_confirm_button` inside another `<form>`: pass `confirm_form:`.** By default it confirms via
**`button_to`**, which renders its own `<form>`, and **nested forms are invalid HTML**: the browser
drops the inner one, so the confirm button submits the OUTER form instead. On the case-contact form
that sent `DELETE /case_contacts/:id/form/details` into a routing error, silently -- the dialog looked
perfect. The Dialog components themselves are fine inside a form; it is `button_to` that is not.

Rather than exiling the control, give the partial **`confirm_form:`** -- the id of a **bodyless
`form_with url:, method:, id:`** rendered outside the enclosing form. The confirm then renders as a
plain submit owned by that form through HTML's `form` attribute, so the trigger and dialog can sit
wherever the design wants while the request still goes to the right place. (Moving the control out of
the row instead was the wrong call: a discard belongs with the actions it is an alternative to.)

**Placement of a destructive action in a form's action row:** same row as the submits, pushed to the
**far end** (`sm:ml-auto`), not adjacent to the primary. That is the compose-toolbar shape -- Gmail
puts Send at one end and discard at the other -- so it is grouped without sitting under a thumb aiming
for Submit. Verify it is genuinely in the row and on the same line (compare `getBoundingClientRect`
tops and the row's right edge), and that no nested `<form>` appeared:
`document.querySelector('#case-contact-form form')` must be null.

**Name the policy predicate after the action.** `authorize @case_contact, :destroy?` still resolved to
`discard_draft?` and raised `NoMethodError`; alias it in the policy
(`alias_method :discard_draft?, :destroy?`) and call a bare `authorize`, like every other alias in
`CaseContactPolicy`.

**A control gated on `persisted?` will not appear on a lazily-created record.** The form persists on
first save and the autosave **never re-renders the page**, so anything server-rendered on
`persisted?` stays as it was at page load -- the Discard button was invisible until a manual reload,
which reads as "the feature does not work". Render such a control **up front with `hidden`**, and let
`case_contact_draft.js#adopt` reveal it and fill in its URL (the create response hands back
`discard_path` beside `id` and `form_action`, so no route is rebuilt in JS). Drive this from the FORM
when testing -- seeding a draft and visiting the wizard URL renders the persisted branch and proves
nothing about the path a user takes. Note the rack_test consequence: a `hidden` block is still
"visible" to rack_test, so assert the **class** in a non-`:js` example and visibility in a `:js` one.

**Discarding a draft** (case-contact form): offered only when the draft actually exists --
`persisted? && !active?`. A brand-new form has nothing to discard (nothing is inserted until the
first save, so **Back** is the whole exit), and an active contact is a real record, deleted from the
list instead. It **hard-deletes** through `CaseContact#discard!` -- the same path the expiry task
uses -- because Paranoia's soft delete keeps the row and resurfaces it to CasaAdmins as a "[DELETE]"
row, i.e. it would leave more clutter than it removed. Its own action (`#discard_draft`) exists so the
redirect can return where the form was opened from; `#destroy` redirects to `request.referer`, which
here is the form of the record just deleted.

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
  `text-slate-600 hover:bg-slate-100`). Nav visibility follows Pundit policies. On desktop the aside is
  **`lg:sticky lg:top-0 lg:h-screen`** (exactly viewport height, stays put as the page scrolls); below
  `lg` it collapses to an off-canvas drawer. That viewport height is what lets a **bottom-pinned item**
  (Settings, via `mt-auto`) sit at the bottom of the *screen* -- a plain `lg:static` column grows with
  the page, so `mt-auto` would strand Settings below the fold (only reachable after scrolling to the
  page end).
- **Sidebar nav order** (**not** alphabetical -- alphabetical is arbitrary vs. how people work):
  **Dashboard first (ungrouped), Settings pinned to the bottom** (`mt-auto` + its own divider), the
  middle **grouped by domain, ordered by frequency** -- Records (Volunteers, Supervisors, Cases) /
  Activity (Case contacts, Learning hours, Other duties, Reimbursements) / Reporting (Reports,
  Analytics, Court reports). Each middle group wears an **uppercase section label** (`text-xs
  font-semibold uppercase tracking-wide text-slate-500`, `mt-4` above); the label does the separating,
  so there are **no between-group dividers** -- the only divider sits above the pinned Settings. Each
  group is a `role="group"` with an **`aria-label`** (the visible label is `aria-hidden` so it isn't
  announced twice); a group whose every item is policy-gated out **renders nothing -- no orphan
  label**. Built from a `nav_groups` array + the `layouts/_nav_link` partial in `layouts/casa_app`.
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
- **Settings (master-detail)** (`casa_org#edit` is the reference): a `max-w-7xl` two-pane — a
  sticky grouped **sub-nav rail** (`hidden lg:block lg:w-48`; **text-only** (icons are noise in a dense grouped list, and a repeated one reads as clutter; the primary sidebar keeps its icons); quiet slate-500 group labels; active
  item `bg-brand-50 text-brand-700`) beside a content column that shows **one section at a time**.
  The `settings-nav` Stimulus controller drives it as **progressive enhancement**: with JS off every
  `[data-settings-nav-target="section"]` stays visible (a plain scroll — so no-JS users and rack_test
  view/request specs see everything); on connect it collapses to one panel, hiding inactive sections
  on desktop (`lg:hidden` on the section, always one panel) while the mobile accordion is a
  **separate concern on a different class** -- the body toggles `max-lg:hidden` (hidden only below lg)
  with its own openKey -- so a mobile collapse never blanks the desktop panel and vice-versa. It
  defaults the desktop panel to the first section (or the URL hash, so deep links keep working -- the
  case-contact form links to `#case-contact-topics`); the mobile accordion starts collapsed. Mobile is
  a grouped accordion (the rail's clusters repeat as `lg:hidden` labels): each section is **one card**
  whose header (title + chevron) toggles the body **open or closed** -- zero or one open, and tapping
  the open header collapses it (the earlier controller could only open, never close). Section **order is by task
  frequency + setup flow, not alphabetical**. **One card per section, responsively:** the `<section>` carries the card chrome on mobile
  (`sec` = overflow-hidden rounded/border/shadow, reset to transparent below `lg`), `acc_btn` is a
  flush header row (not its own card), a `panel_body` adds the under-header divider, and the inner
  panels -- the `card` local and every entity partial -- drop their card chrome below `lg`
  (`p-5 sm:p-6 lg:rounded-2xl lg:border lg:bg-white lg:shadow-sm`) so they read as the card body, not
  a second nested card. Each single-section partial's title `<h3>` is `hidden lg:block` (the accordion
  header is the title on mobile; the `<h3>` is the panel title on desktop; multi-card sections keep
  their sub-headings). Verify by geometry: on mobile the `<section>` owns the border/radius and the
  inner panel has none; on desktop it flips. Tables/anchor ids are unchanged; the page heading is
  **"Settings"** (matching the sidebar nav label -- the app-wide convention is h1 == nav label), the
  "Manage …" section headings stay, and the **Court** group splits into Hearing types / Judges / Sent
  emails. The **Administration** group is **direct links** to the standalone admin pages (admins,
  mileage rates, banners, imports) -- not an in-page panel -- shown in the rail on desktop and, on
  mobile, **tappable text-only cards that match the section headers** (same card chrome + bold label;
  a `chevron-right` for navigate vs the sections' `chevron-down` for expand -- no leading icons, since
  the rest of the settings nav is text-only), so each page is one click away (no panel-of-cards detour). Those
  standalone pages **share the settings frame**: `casa_org/_settings_frame` renders the same header +
  persistent rail (their item highlighted) + content at `max-w-7xl`, and `casa_org/_settings_rail` is
  the one rail used by both edit (`panels: true`, JS panel-switch) and the admin pages (`panels:
  false`, hash-nav to a section). On mobile the rail is hidden, so a **"Back to settings"** link is
  the return path.
- **Back navigation on sub-pages.** Every casa_app page reached *from* another page (a form, detail,
  or action destination -- not a sidebar/top-level nav item) has a way back: either a **breadcrumb**
  (a brand-600 parent link at the top -- "Cases", "Cases / CINA-1", or a bare "Case number: ->case")
  or the **chevron** "Back to X" (`inline-flex items-center gap-1 text-sm font-medium text-slate-500
  hover:text-slate-700` + `bi-chevron-left`). Top-level destinations (Dashboard, Cases, Settings, etc.)
  don't need one. Add a back affordance to every new sub-page -- it's a recurring gap (bulk court
  dates, case groups, the emancipation-checklists index, and the **case-contact form** were dead-ends
  until audited). On the case-contact form the back link points at the existing **`#leave`** action
  (`redirect_back_to_referer`, falling back to the list), so Back lands exactly where a successful
  Submit would -- that action was already routed and nothing linked to it. Its label is a bare
  **`Back`**, not `Back to X`, because the destination is the referer and so varies; and it is **not
  `Cancel`** -- the form autosaves, so on an existing contact the changes are already saved and
  offering to cancel them would be a lie.
  **Spacing/placement (verified 8px gap, pixel-identical across pages).** The back link + title are
  one header block with an **8px gap** below the link -- `mt-2` on the title when they share a wrapper,
  `mb-2` when the link is its own block. Never leave the link as a **bare child of a `space-y-*`
  container**: the 6-unit rhythm (24px) then lands between the link and the title and shoves everything
  down (the `casa_cases#show` regression measured 32px vs. the correct 9px). Three shapes:
  - **h1-only:** one `<div>` = back link + `<h1 class="mt-2 ...">` (+ optional subtitle).
  - **title + actions, no subtitle** (`casa_cases#show`, `learning_hours#show`): the back link +
    `<h1 class="mt-2 ...">` are the **left column** of a `flex items-end justify-between` row; the
    actions are the right column and **bottom-align to the title** (matches the index-page headers).
  - **title + actions, with a subtitle** (`case_groups#index`): the back link is a `mb-2` block
    **above** a `flex items-start justify-between` row, so the actions top-align with the title, not
    the bottom of the (tall) subtitle -- putting the link inside the left column with `items-end` here
    would sink the buttons to the subtitle's bottom.
  - **`shared/_page_header` is the single implementation** (2026-07-27): `render "shared/page_header",
    back: {path:, label:}, title:, subtitle:` (optional `wrapper_class:`, e.g. "mb-6" when the header is not
    a `space-y-*` child). It renders the ONE correct header block (back link + `h1 mt-2` + optional
    subtitle), so the spacing can't drift per page. **Use it for every new sub-page.** Audited all 19
    header pages: the 16 simple back+title(+subtitle) headers were converted to it (`volunteers/new` had
    regressed to the bare-`space-y-6` anti-pattern -> 24px, which triggered this); pixel-verified 9px
    across the space-y / `mb-6` / with-subtitle variants; view spec at `spec/views/shared/_page_header...`.
    The 3 person-edit pages (`volunteers/edit`, `supervisors/edit`, `casa_admins/edit`) keep bespoke
    headers -- identity name/email subtitle + volunteers/edit's Impersonate/reminder actions, shapes the
    partial deliberately doesn't cover. Root cause of the recurrence was per-page hand-written headers +
    this checkout's working-tree reverts reintroducing stale ones; the partial removes the per-page copy.
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
- **Build:** `npm run build:css` (minified) or `build:css:dev` (watch, the `tw`
  process in `Procfile.dev`). Class names are discovered via the `@source` globs in
  `tailwind.css`. The output `app/assets/builds/tailwind.css` is **gitignored** and built
  on deploy — don't commit it. Keep the script named `build:css`: `cssbundling-rails`
  runs `npm run build:css` during `assets:precompile`, so renaming it breaks the deploy.
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
7. **Verify:** `npm run build:css`, run the page's specs, then `bin/lint`. Confirm the
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
- [x] Other app-shell leaf pages (impersonation banner + flash parity + footer shipped — the casa_app
  footer restores parity with the all-casa shell: Built by Ruby For Good / Report a site issue (the
  help/support link) / SMS Terms & Conditions, `border-t px-4 py-5 text-xs text-slate-500`, after `<main>`.
  `py-5` (not py-4) makes the footer 57px so its top rule lands on the same y as the sidebar's pinned
  Settings divider (the sticky h-screen sidebar puts that 57px block at the viewport bottom too) — verified aligned)
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

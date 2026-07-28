require "rails_helper"

RSpec.describe "case_contacts/index", type: :system do
  subject { visit case_contacts_path }

  let(:volunteer) { build(:volunteer, display_name: "Bob Loblaw", casa_org: organization) }
  let(:organization) { build(:casa_org) }

  before { sign_in volunteer }

  context "with case contacts" do
    let(:case_number) { "CINA-1" }
    let(:casa_case) { build(:casa_case, casa_org: organization, case_number: case_number) }
    let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }

    context "without filter" do
      it "can see case creator in card" do
        create(:case_contact, creator: volunteer, casa_case: casa_case, occurred_at: 2.days.ago)

        subject

        within(".full-card", match: :first) do
          expect(page).to have_text("Bob Loblaw")
        end
      end

      it "can navigate to edit volunteer page" do
        subject

        expect(page).to have_no_link("Bob Loblaw")
      end

      it "allows the volunteer to delete a draft they created" do
        create(:case_contact, creator: volunteer, casa_case: casa_case, occurred_at: 2.days.ago)
        create(:case_contact, :started_status, creator: volunteer, casa_case: casa_case, occurred_at: 3.days.ago,
          contact_types: [build(:contact_type, name: "DRAFT Case Contact")])

        subject

        card = find(".container-fluid", text: "DRAFT Case Contact")
        expect(card).not_to be_nil

        within_element(card) do
          expect(card).to have_text("Draft")
          click_on "Delete"
        end

        expect(page).to have_no_css(".container-fluid", text: "DRAFT Case Contact")
      end

      it "displays the contact type groups" do
        create(:case_contact, creator: volunteer, casa_case: casa_case, occurred_at: Time.zone.now,
          contact_types: [build(:contact_type, name: "Most Recent Case Contact")])
        create(:case_contact, :started_status, creator: volunteer, casa_case: casa_case, occurred_at: 3.days.ago,
          contact_types: [build(:contact_type, name: "DRAFT Case Contact")])

        subject

        expect(page).to have_text("Most Recent Case Contact")
        expect(page).to have_text("DRAFT Case Contact")
      end
    end

    describe "reimbursement status" do
      it "shows a pending badge when the reimbursement has not been completed" do
        create(:case_contact, :wants_reimbursement, creator: volunteer, casa_case: casa_case,
          occurred_at: 2.days.ago, reimbursement_complete: false)

        subject

        within(".full-card", match: :first) do
          expect(page).to have_text("Reimbursement Pending")
          expect(page).to have_no_text("Reimbursement Complete")
        end
      end

      it "shows a complete badge when the reimbursement has been completed" do
        create(:case_contact, :wants_reimbursement, creator: volunteer, casa_case: casa_case,
          occurred_at: 2.days.ago, reimbursement_complete: true)

        subject

        within(".full-card", match: :first) do
          expect(page).to have_text("Reimbursement Complete")
          expect(page).to have_no_text("Reimbursement Pending")
        end
      end

      it "shows no reimbursement badge when reimbursement was not requested" do
        create(:case_contact, creator: volunteer, casa_case: casa_case, occurred_at: 2.days.ago,
          want_driving_reimbursement: false)

        subject

        within(".full-card", match: :first) do
          expect(page).to have_no_text("Reimbursement Pending")
          expect(page).to have_no_text("Reimbursement Complete")
        end
      end
    end

    describe "automated filtering case contacts" do
      describe "by date of contact" do
        it "only shows the contacts with the correct date", :js do
          yesterday = Time.zone.yesterday
          day_before_yesterday = yesterday - 1.day
          today = Time.zone.today
          create(:case_contact, creator: volunteer, casa_case: casa_case, occurred_at: day_before_yesterday)
          create(:case_contact, creator: volunteer, casa_case: casa_case, occurred_at: yesterday)
          create(:case_contact, creator: volunteer, casa_case: casa_case, occurred_at: today)
          subject

          click_on "More filters"

          yesterday_display = I18n.l(yesterday, format: :full, default: nil)
          day_before_yesterday_display = I18n.l(day_before_yesterday, format: :full, default: nil)
          today_display = I18n.l(today, format: :full, default: nil)
          expect(page).to have_content day_before_yesterday_display
          expect(page).to have_content yesterday_display
          expect(page).to have_content today_display

          fill_in "filterrific_occurred_starting_at", with: yesterday
          fill_in "filterrific_occurred_ending_at", with: Time.zone.tomorrow

          expect(page).to have_no_content day_before_yesterday_display
          expect(page).to have_content yesterday_display
          expect(page).to have_content today_display
        end
      end

      describe "by casa_case_id" do
        subject { visit case_contacts_path(casa_case_id: casa_case.id) }

        let!(:other_casa_case) { build(:casa_case, casa_org: organization, case_number: "CINA-2") }

        it "displays the draft" do
          create(:case_contact, :details_status, creator: volunteer, draft_case_ids: [casa_case.id])

          subject

          expect(page).to have_no_content "You have no case contacts for this case."
          expect(page).to have_content "Draft"
        end

        it "only displays the filtered case" do
          subject

          expect(page).to have_no_content other_casa_case.case_number
          expect(page).to have_content casa_case.case_number
        end
      end

      describe "by hide drafts" do
        it "does not show draft contacts", :js do
          build(:case_contact, creator: volunteer, casa_case: casa_case)
          build(:case_contact, :started_status, creator: volunteer, casa_case: casa_case)
          subject

          check "Hide drafts"

          expect(page).to have_no_content "Draft"
        end
      end

      describe "collapsing filter menu" do
        before do
          subject
        end

        it "displays sticky filters before clicking expand" do
          expect(page).to have_field "Hide drafts", type: :checkbox
        end

        it "does not expand menu when filtering only by sticky filter", :js do
          check "Hide drafts"

          expect(page).to have_field "Hide drafts", type: :checkbox
          expect(page).to have_no_content "Other filters"
        end

        it "displays other filters when expanded" do
          click_on "More filters"

          expect(page).to have_content "Other filters"
        end

        # Tailwind v4 emits rotate-180 as the standalone `rotate` property, so read that --
        # `transform` is "none" in both states and would pass a broken rotation.
        it "rotates the trigger chevron when expanded", :js do
          chevron = "[data-disclosure-target=trigger] i"
          expect(page.evaluate_script("getComputedStyle(document.querySelector('#{chevron}')).rotate")).to eq("none")

          click_on "More filters"
          expect(page).to have_content "Other filters"

          expect(page.evaluate_script("getComputedStyle(document.querySelector('#{chevron}')).rotate")).to eq("180deg")
        end

        it "does not hide menu when filtering by placement filter" do
          click_on "More filters"
          select "In person", from: "Contact medium"

          expect(page).to have_content "Other filters"
        end
      end

      # The panel's open state used to be re-derived from expand_filters? on every render, and the
      # form auto-submits, so any change that left no hidden filter active slammed the panel shut
      # under the user -- clearing the contact types, setting a select back to All, or merely ticking
      # Hide drafts. It is now the user's state, round-tripped through a hidden field.
      describe "panel stays where the user put it", :js do
        let(:group) { create(:contact_type_group, casa_org: organization, name: "CASA") }
        let!(:youth) { create(:contact_type, contact_type_group: group, name: "Youth") }

        it "stays open when a surfaced filter is touched" do
          subject
          click_on "More filters"
          expect(page).to have_content "Other filters"

          check "Hide drafts"

          expect(page).to have_field("Hide drafts", checked: true)
          expect(page).to have_content "Other filters"
        end

        it "stays open when the last hidden filter is cleared" do
          visit case_contacts_path(filterrific: {contact_type: [youth.id.to_s]})
          expect(page).to have_content "Other filters"

          find(".clear-button").click

          expect(page).to have_no_css(".ts-control .item")
          expect(page).to have_content "Other filters"
        end

        it "stays open when a hidden select goes back to All" do
          visit case_contacts_path(filterrific: {contact_medium: "in-person"})
          expect(page).to have_content "Other filters"

          select "All", from: "Contact medium"

          expect(page).to have_select("Contact medium", selected: "All")
          expect(page).to have_content "Other filters"
        end

        it "stays closed once the user closes it, even with a filter active" do
          visit case_contacts_path(filterrific: {contact_medium: "in-person"})
          expect(page).to have_content "Other filters"

          click_on "More filters" # close it
          expect(page).to have_no_content "Other filters"

          check "Hide drafts"

          expect(page).to have_field("Hide drafts", checked: true)
          expect(page).to have_no_content "Other filters"
        end
      end

      describe "filter toolbar" do
        # Clear renders exactly when clicking it would change something -- never at the defaults,
        # where it would be dead chrome.
        it "hides Clear filters at the defaults" do
          subject

          expect(page).to have_no_link("Clear filters")
        end

        it "hides Clear filters when only the default sort is set" do
          visit case_contacts_path(filterrific: {sorted_by: "occurred_at_desc"})

          expect(page).to have_no_link("Clear filters")
        end

        it "shows Clear filters once a filter is applied" do
          visit case_contacts_path(filterrific: {contact_medium: "in-person"})

          expect(page).to have_link("Clear filters")
        end

        it "keeps Hide drafts on one line with the overflow trigger", :js do
          subject

          centres = page.evaluate_script(<<~JS)
            (function () {
              function cy (sel) {
                var r = document.querySelector(sel).getBoundingClientRect();
                return Math.round((r.top + r.bottom) / 2);
              }
              return [cy('#filterrific_sorted_by'), cy('#filterrific_no_drafts'), cy('[data-disclosure-target=trigger]')];
            })()
          JS

          expect(centres.uniq.size).to eq(1), "sort / Hide drafts / More filters centres differ: #{centres.inspect}"
        end
      end

      describe "contact types filter" do
        let(:group) { create(:contact_type_group, casa_org: organization, name: "CASA") }
        let!(:youth) { create(:contact_type, contact_type_group: group, name: "Youth") }
        let!(:school) { create(:contact_type, contact_type_group: group, name: "School") }

        # Was an exposed grid of ~25 checkboxes (502px desktop / 954px mobile, taller than the
        # results). Now one searchable multiselect, so guard the pieces that make it work.
        it "renders one searchable multiselect with the groups as optgroups" do
          subject

          select = page.find("#filterrific_contact_type", visible: :all)
          expect(select[:multiple]).to be_truthy
          expect(page).to have_css("#filterrific_contact_type optgroup[label='CASA']", visible: :all)
          # Deliberately NOT `filter-input`: that hook submits on every change, which re-rendered the
          # page under the open menu. This control defers its submit to the menu closing instead.
          expect(select[:class]).not_to include("filter-input")
          expect(page).to have_css("[data-multiple-select-submit-on-close-value='true']", visible: :all)
        end

        it "filters the list when a type is picked", :js do
          create(:case_contact, creator: volunteer, casa_case: casa_case, contact_types: [youth])
          create(:case_contact, creator: volunteer, casa_case: casa_case, contact_types: [school])

          subject
          click_on "More filters"
          expect(page).to have_text("Showing 1\u20132 of 2")

          find(".ts-control").click
          find(".ts-dropdown .option", text: "Youth", match: :first).click
          find("#filterrific_sorted_by").click # the selection applies when the menu closes

          expect(page).to have_text("Showing 1\u20131 of 1")
        end

        it "shows the active type as a chip when it arrives in the params", :js do
          visit case_contacts_path(filterrific: {contact_type: [youth.id.to_s]})

          expect(page).to have_css(".ts-control .item", text: "Youth")
        end

        # tom-select ships the clear-all at opacity 0, revealed only on hover/focus -- no visible way
        # to empty a control full of chips, and unreachable by hover on touch. `find` here only
        # matches a VISIBLE element, so this fails if that reveal is ever gated again.
        it "offers a visible clear-all inside the field that empties it", :js do
          create(:case_contact, creator: volunteer, casa_case: casa_case, contact_types: [youth])
          create(:case_contact, creator: volunteer, casa_case: casa_case, contact_types: [school])
          visit case_contacts_path(filterrific: {contact_type: [youth.id.to_s, school.id.to_s]})

          expect(page).to have_css(".ts-control .item", count: 2)

          find(".clear-button").click

          expect(page).to have_no_css(".ts-control .item")
          expect(page).to have_text("Showing 1\u20132 of 2")
        end

        # The auto-submit re-rendered the page on every chip, tearing down the open menu: picking N
        # types cost N page loads and N reopenings. The submit is now held until the menu closes.
        it "takes several picks in one menu session, then submits once", :js do
          create(:contact_type, contact_type_group: group, name: "Court")
          subject
          click_on "More filters"
          find(".ts-control").click

          page.execute_script("window.__tag = 'same-document'")

          ["Youth", "School", "Court"].each do |name|
            find(".ts-dropdown .option", text: name, match: :first).click
            expect(page).to have_css(".ts-control .item", text: name)
            # Same document, menu still open: no submit happened for this pick.
            expect(page.evaluate_script("window.__tag")).to eq("same-document")
          end

          expect(page).to have_css(".ts-control .item", count: 3)

          find("#filterrific_sorted_by").click # leaving the menu applies the whole selection

          expect(page).to have_current_path(/contact_type/, url: true)
          expect(page.current_url.scan(/contact_type%5D%5B%5D=\d+/).size).to eq(3)
        end

        it "gives the menu's group headers their own visual level", :js do
          subject
          click_on "More filters"
          find(".ts-control").click
          expect(page).to have_css(".ts-dropdown .optgroup-header")

          style = page.evaluate_script(<<~JS)
            (function () {
              var h = getComputedStyle(document.querySelector('.ts-dropdown .optgroup-header'));
              var o = getComputedStyle(document.querySelector('.ts-dropdown .option'));
              return {
                weight: h.fontWeight,
                transform: h.textTransform,
                headerPad: h.paddingLeft,
                optionPad: o.paddingLeft,
                sameWeight: h.fontWeight === o.fontWeight
              };
            })()
          JS

          # tom-select ships headers at the options' weight with 4px less left padding, which read as
          # a misaligned option rather than a header.
          expect(style["transform"]).to eq("uppercase")
          expect(style["sameWeight"]).to eq(false)
          expect(style["headerPad"]).to eq(style["optionPad"])
        end

        it "keeps the clear-all keyboard reachable and named", :js do
          visit case_contacts_path(filterrific: {contact_type: [youth.id.to_s]})

          clear = find(".clear-button")
          expect(clear[:role]).to eq("button")
          expect(clear[:tabindex]).to eq("0")
          expect(clear[:title]).to eq("Clear all selections")
        end
      end

      describe "active filter count" do
        it "shows no badge when no hidden filter is on" do
          subject

          expect(page).to have_no_css("[data-disclosure-target=trigger] span.rounded-full")
        end

        it "counts hidden filters, one per field" do
          visit case_contacts_path(filterrific: {contact_medium: "in-person", contact_made: "true"})

          expect(page).to have_css("[data-disclosure-target=trigger] span.rounded-full", text: "2")
        end

        it "excludes the filters already visible in the toolbar row" do
          visit case_contacts_path(filterrific: {no_drafts: "1", sorted_by: "occurred_at_asc"})

          expect(page).to have_no_css("[data-disclosure-target=trigger] span.rounded-full")
        end
      end

      describe "other filters" do
        # These three selects once passed `class:` in f.select's options hash instead of
        # html_options, so they rendered with no class at all: unstyled, and missing the
        # `filter-input` hook the form auto-submits on, which left them inert.
        it "styles the selects and keeps the auto-submit hook" do
          subject

          %w[filterrific_contact_medium filterrific_want_driving_reimbursement filterrific_contact_made].each do |id|
            classes = page.find("##{id}", visible: :all)[:class].to_s
            expect(classes).to include("filter-input")
            expect(classes).to include("rounded-lg")
          end
        end

        it "offers All as the unfiltered option" do
          subject

          expect(page).to have_select("Contact medium", with_options: ["All"], visible: :all)
          expect(page).to have_select("Contact made", with_options: ["All"], visible: :all)
          expect(page).to have_select("Want driving reimbursement", with_options: ["All"], visible: :all)
        end

        it "shows the active contact medium as selected" do
          visit case_contacts_path(filterrific: {contact_medium: "in-person"})

          expect(page).to have_select("Contact medium", selected: "In person", visible: :all)
        end

        it "filters by contact medium", :js do
          create(:case_contact, creator: volunteer, casa_case: casa_case, medium_type: "in-person")
          create(:case_contact, creator: volunteer, casa_case: casa_case, medium_type: "letter")

          subject
          click_on "More filters"
          expect(page).to have_text("Showing 1\u20132 of 2")

          select "In person", from: "Contact medium"

          expect(page).to have_text("Showing 1\u20131 of 1")
        end
      end
    end

    describe "case contacts text color" do
      let(:contact_group_text) { case_contact.contact_groups_with_types.keys.first }

      context "with active case contact" do
        let!(:case_contact) { create(:case_contact, creator: volunteer, casa_case: casa_case, occurred_at: Time.zone.yesterday) }

        it "displays correct color for contact" do
          subject

          within ".card-title" do
            expect(page).to have_content(contact_group_text)
          end
        end
      end
    end

    it "can show only case contacts for one case", :js do
      yesterday = Time.zone.yesterday
      day_before_yesterday = yesterday - 1.day
      today = Time.zone.today
      create(:case_contact, creator: volunteer, casa_case: casa_case, notes: "Case 1 Notes", occurred_at: day_before_yesterday)

      another_case_number = "CINA-2"
      another_case = build(:casa_case, casa_org: organization, case_number: another_case_number)
      create(:case_assignment, volunteer: volunteer, casa_case: another_case)
      create(:case_contact, creator: volunteer, casa_case: another_case, notes: "Case 2 Notes", occurred_at: today)

      # showing all cases -> both case sections render (case number is the section heading)
      visit case_contacts_path
      expect(page).to have_content(case_number)
      expect(page).to have_content(another_case_number)

      # showing case 1 only
      visit case_contacts_path(casa_case_id: casa_case.id)
      expect(page).to have_content(case_number)
      expect(page).to have_no_content(another_case_number)

      # showing case 2 only
      visit case_contacts_path(casa_case_id: another_case.id)
      expect(page).to have_content(another_case_number)
      expect(page).to have_no_content(case_number)

      # a date range that keeps case 2's contact (today) and drops case 1's (day before yesterday)
      click_on "More filters"
      fill_in "filterrific_occurred_starting_at", with: yesterday
      fill_in "filterrific_occurred_ending_at", with: Time.zone.tomorrow

      expect(page).to have_content(another_case_number)
      expect(page).to have_no_content(case_number)

      # case 1 + a date range that excludes its only contact -> no contact cards render
      visit case_contacts_path(casa_case_id: casa_case.id)
      click_on "More filters"
      fill_in "filterrific_occurred_starting_at", with: yesterday
      fill_in "filterrific_occurred_ending_at", with: Time.zone.tomorrow

      expect(page).to have_no_css(".full-card")
    end

    describe "contact notes" do
      let(:contact_topics) { build_list(:contact_topic, 2, casa_org: organization) }
      let(:contact_topic) { contact_topics.first }
      let(:case_contact) { build(:case_contact, casa_case:, creator: volunteer) }
      let!(:contact_topic_answer) do
        create(:contact_topic_answer, case_contact:, contact_topic:)
      end

      let(:user) { volunteer }

      before { sign_in user }

      it "reveals topic answers and notes in one expandable details section", :js do
        subject

        # the topic's help text (details) is never rendered
        expect(page).to have_no_text contact_topics.first.details
        # answers stay collapsed behind a single toggle until the card is expanded
        expect(page).to have_no_content(contact_topic_answer.value)

        find("summary", text: "Show details", match: :first).click

        expect(page).to have_content(contact_topic.question)
        expect(page).to have_content(contact_topic_answer.value)
        expect(page).to have_no_content contact_topics.first.details
      end
    end
  end

  context "without case contacts" do
    it "shows helper text" do
      subject
      expect(page).to have_text("You have no case contacts for this case. Please click New case contact button above to create a case contact for your youth!")
    end
  end
end

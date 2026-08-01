require "rails_helper"

# Every TomSelect control: does typing filter, and after selecting is the typed text gone and the
# value registered. Controls are found via their native <select> (page position is unreliable -- one
# page has a control inside a closed <dialog>). Every problem is named in the failure message.
RSpec.describe "typeahead audit", :js, type: :system do
  let!(:organization) { create(:casa_org) }
  let!(:admin) { create(:casa_admin, casa_org: organization) }
  let!(:supervisor) { create(:supervisor, casa_org: organization, display_name: "Zelda Zimmerman") }
  let!(:volunteer) { create(:volunteer, :with_cases_and_contacts, casa_org: organization, supervisor: supervisor, display_name: "Quentin Quackenbush") }
  let!(:decoy_vol) { create(:volunteer, casa_org: organization, supervisor: supervisor, display_name: "Aaron Ackerman") }
  let!(:kase) { create(:casa_case, casa_org: organization, case_number: "ZZZ-9999") }
  let!(:decoy_case) { create(:casa_case, casa_org: organization, case_number: "AAA-1111") }
  let!(:ctg) { create(:contact_type_group, casa_org: organization, name: "Zebra group") }
  let!(:ct) { create(:contact_type, contact_type_group: ctg, name: "Zebra type") }
  let!(:ctg2) { create(:contact_type_group, casa_org: organization, name: "Alpha group") }
  let!(:ct2) { create(:contact_type, contact_type_group: ctg2, name: "Alpha type") }
  let!(:lh) { create(:learning_hour, user: volunteer) }
  # The reimbursement filter lists only volunteers who actually have a reimbursement.
  let!(:reimbursement) { create(:case_contact, :wants_reimbursement, creator: volunteer, casa_case: kase) }
  let!(:duty) { create(:other_duty, creator: volunteer) }
  let!(:unassigned) { create(:volunteer, casa_org: organization, supervisor: nil, display_name: "Nadia Nobody") }
  let!(:transitioning) do
    ["ZZT-8888", "ZZT-7777"].map do |number|
      c = create(:casa_case, casa_org: organization, case_number: number,
        birth_month_year_youth: (CasaCase::TRANSITION_AGE + 1).years.ago)
      create(:case_assignment, volunteer: volunteer, casa_case: c, active: true)
      c
    end
  end

  # Tag the control's wrapper so Capybara can address it: TomSelect exposes it as select.tomselect.wrapper.
  # A fresh id per call: several controls live on one page, and reusing one id makes the lookup
  # ambiguous (and on the court-report page it collided with a control inside a closed <dialog>).
  def wrapper_for(select_css, tag)
    page.evaluate_script(<<~JS)
      (function() {
        const sel = document.querySelector(#{select_css.to_json})
        if (!sel || !sel.tomselect) return null
        sel.tomselect.wrapper.id = #{tag.to_json}
        return #{tag.to_json}
      })()
    JS
  end

  def audit(label, select_css, query:, expect_option:, absent_option: nil)
    @audit_seq = (@audit_seq || 0) + 1
    tag = "audit-target-#{@audit_seq}"
    id = nil
    Timeout.timeout(6) do
      loop do
        id = wrapper_for(select_css, tag)
        break if id
        sleep 0.2
      end
    end
    # The wrapper is tagged so the chip check below can address it; interaction goes through the
    # TomSelect instance rather than the wrapper element.
    expect(page).to have_css("##{id}", visible: :all)

    # Close any menu left open by the previous control: .ts-dropdown is not scoped to a control, so a
    # leftover one intercepts the click.
    page.execute_script("document.querySelectorAll('select').forEach(s => s.tomselect && s.tomselect.close())")
    page.execute_script("document.activeElement && document.activeElement.blur()")

    # Focus through TomSelect's own API rather than clicking .ts-control: inside a just-opened modal
    # the click target moves and Selenium intermittently raised ElementNotInteractable / missed the
    # input entirely. This still opens the menu and puts real keystrokes into the real input.
    page.execute_script("document.querySelector(#{select_css.to_json}).tomselect.focus()")
    page.driver.browser.switch_to.active_element.send_keys(query)

    problems = []
    typed_ok = false
    deadline = Time.current + 4
    until typed_ok || Time.current > deadline
      typed_ok = page.evaluate_script("(document.querySelector(#{select_css.to_json}).tomselect.control_input.value || '')") == query
      sleep 0.1
    end

    # Filtering IS asserted now, where the fixtures give a decoy to look for the absence of. Earlier
    # attempts were racy because they READ the menu (a fixed sleep lands mid-filter; `currentResults`
    # is not the post-query set; a count read straight after the keystrokes reads the pre-filter DOM).
    # A waiting matcher on the decoy's absence retries until the filter lands, and only the open menu
    # is visible so the global `.ts-dropdown` cannot match another control's.
    if absent_option
      problems << "menu still lists #{absent_option.inspect} after typing #{query.inspect}" unless
        page.has_no_css?(".ts-dropdown .option", text: absent_option)
      problems << "menu lost #{expect_option.inspect} after typing #{query.inspect}" unless
        page.has_css?(".ts-dropdown .option", text: expect_option)
    end

    find(".ts-dropdown .option", text: expect_option, match: :first).click
    page.has_css?("##{id} .ts-control .item", wait: 3)

    state = page.evaluate_script(<<~JS)
      (function() {
        const sel = document.querySelector(#{select_css.to_json})
        const ts = sel.tomselect
        return {
          typed: ts.control_input ? ts.control_input.value : null,
          items: ts.items.length,
          selected: [...sel.selectedOptions].map(o => o.text).filter(t => t.trim()).length,
          multi: ts.settings.mode === 'multi'
        }
      })()
    JS

    problems << "typed text remained #{state["typed"].inspect}" unless state["typed"].to_s.empty?
    problems << "nothing selected in the control" if state["items"].to_i.zero?
    problems << "native select not updated" if state["selected"].to_i.zero?
    problems << "query never reached the control input" unless typed_ok
    @results << [label, problems]
  rescue => e
    @results << [label, ["#{e.class}: #{e.message.to_s.lines.first.to_s.strip[0, 70]}"]]
  end

  it "every control filters as you type, then clears the query and registers the value" do
    @results = []
    allow(Flipper).to receive(:enabled?).and_call_original
    allow(Flipper).to receive(:enabled?).with(:new_case_contact_table).and_return(true)
    begin
      sign_in admin

      visit case_contacts_path
      find("[data-disclosure-target='trigger']").click
      audit("case_contacts#index contact types", "select[name='filterrific[contact_type][]']", query: "Zebra", expect_option: "Zebra type", absent_option: "Alpha type")

      visit case_contacts_new_design_path
      find("[data-disclosure-target='trigger']").click if page.has_css?("[data-disclosure-target='trigger']", wait: 2)
      audit("new_design cases", "#casa_case_ids", query: "ZZZ", expect_option: "ZZZ-9999", absent_option: "AAA-1111")
      audit("new_design contact types", "#contact_type_ids", query: "Zebra", expect_option: "Zebra type", absent_option: "Alpha type")

      visit new_case_group_path
      audit("case_groups#new cases", "select[name='case_group[casa_case_ids][]']", query: "ZZZ", expect_option: "ZZZ-9999", absent_option: "AAA-1111")

      visit learning_hours_path
      audit("learning_hours volunteer", "select[name='search']", query: "Quen", expect_option: "Quentin Quackenbush")

      visit other_duties_path
      audit("other_duties volunteer", "select[name='search']", query: "Quen", expect_option: "Quentin Quackenbush")

      visit reports_path
      audit("reports supervisors", "select[name='report[supervisor_ids][]']", query: "Zeld", expect_option: "Zelda Zimmerman")
      audit("reports volunteers", "select[name='report[creator_ids][]']", query: "Quen", expect_option: "Quentin Quackenbush", absent_option: "Aaron Ackerman")
      audit("reports contact types", "select[name='report[contact_type_ids][]']", query: "Zebra", expect_option: "Zebra type", absent_option: "Alpha type")
      audit("reports contact type groups", "select[name='report[contact_type_group_ids][]']", query: "Zebra", expect_option: "Zebra group", absent_option: "Alpha group")

      visit supervisors_path
      audit("supervisors#index assign", "select[name='supervisor_volunteer[supervisor_id]']", query: "Zeld", expect_option: "Zelda Zimmerman")

      visit edit_casa_case_path(kase)
      audit("casa_cases#edit assign volunteer", "#case_assignment_casa_case_id", query: "Aaro", expect_option: "Aaron Ackerman", absent_option: "Quentin Quackenbush")

      visit edit_volunteer_path(volunteer)
      audit("volunteers#edit assign case", "#case_assignment_casa_case_id", query: "AAA", expect_option: "AAA-1111", absent_option: "ZZZ-9999")

      # A volunteer who already HAS a supervisor renders the current-supervisor branch, not the assign
      # form -- so this one is audited on the unassigned volunteer.
      visit edit_volunteer_path(unassigned)
      audit("volunteers#edit assign supervisor", "#supervisor_volunteer_supervisor_id", query: "Zeld", expect_option: "Zelda Zimmerman")

      visit edit_supervisor_path(supervisor)
      audit("supervisors#edit assign volunteer", "select[name='supervisor_volunteer[volunteer_id]']", query: "Nadi", expect_option: "Nadia Nobody")

      visit new_casa_case_path
      audit("casa_cases#new assign volunteer", "select[name*='volunteer_id']", query: "Aaro", expect_option: "Aaron Ackerman", absent_option: "Quentin Quackenbush")

      # Filter-bar pickers (a person list among short native selects), not assign pickers.
      visit reimbursements_path
      audit("reimbursements#index volunteer filter", "#volunteers", query: "Quen", expect_option: "Quentin Quackenbush", absent_option: "All volunteers")

      visit volunteers_path
      audit("volunteers#index supervisor filter", "#supervisor", query: "Zeld", expect_option: "Zelda Zimmerman", absent_option: "All supervisors")

      # The bulk assign-supervisor picker lives inside a dialog whose trigger only appears once a
      # volunteer row is checked.
      first("[id^='supervisor_volunteer_volunteer_ids_']").click
      find("[data-select-all-target='button']").click
      audit("volunteers#index bulk assign (in dialog)", "#supervisor_volunteer_supervisor_id", query: "Zeld",
        expect_option: "Zelda Zimmerman", absent_option: "None")

      visit case_court_reports_path
      # This picker lives inside the "Generate report" Dialog, so it does not exist on screen until
      # the modal is opened -- not a broken control, just one behind a trigger.
      click_on "Generate report"
      expect(page).to have_css("dialog[open]")
      audit("court report case picker (in modal)", "#case-selection", query: "ZZZ", expect_option: "ZZZ-9999", absent_option: "AAA-1111")

      # Volunteer-only page; as an admin the visit redirects to the dashboard.
      sign_out admin
      sign_in volunteer
      visit emancipation_checklists_path
      audit("emancipation_checklists case", "select[name='search']", query: "ZZT", expect_option: "ZZT-8888")
    end

    # Guards the inventory itself: a new TomSelect control should be added here too.
    expect(@results.size).to(eq(21), "expected 21 controls, audited #{@results.size} -- one was added or removed")
    failures = @results.reject { |(_, problems)| problems.empty? }
    expect(failures).to be_empty, "typeahead problems:\n" + failures.map { |l, p| "  #{l}: #{p.join("; ")}" }.join("\n")
  end
end

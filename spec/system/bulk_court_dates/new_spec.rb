# frozen_string_literal: true

require "rails_helper"

RSpec.describe "bulk_court_dates/new", type: :system do
  let(:now) { Date.new(2021, 1, 1) }
  let(:casa_org) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: casa_org) }
  let!(:casa_case) { create(:casa_case, casa_org: casa_org) }
  let!(:court_date) { create(:court_date, :with_court_details, casa_case: casa_case, date: now - 1.week) }
  let!(:judge) { create(:judge) }
  let!(:hearing_type) { create(:hearing_type) }
  let(:court_order_text) { Faker::Lorem.paragraph(sentence_count: 2) }

  it "is successful", :js do
    case_group = build(:case_group, casa_org: casa_org)
    case_group.case_group_memberships.first.casa_case = casa_case
    case_group.save!

    travel_to now
    sign_in admin
    visit casa_cases_path
    find("summary", text: "More").click
    click_on "New bulk court date"

    select case_group.name, from: "Case group"
    fill_in "court_date_date", with: :now
    fill_in "court_date_court_report_due_date", with: :now
    select judge.name, from: "Judge"
    select hearing_type.name, from: "Hearing type"

    click_on "Add a court order"
    # Use Capybara's finder rather than caching a raw Selenium reference: the court-order row is
    # cloned from a <template> by the court-order-form controller, so a `.native` handle grabbed
    # from `first` while that insertion is still settling goes stale, and send_keys then fails with
    # "Node with given id does not belong to the document". find/#set re-resolves and waits.
    find("textarea.court-order-text-entry").set(court_order_text)
    page.find("select.implementation-status").find(:option, text: "Partially implemented").select_option

    within ".top-page-actions" do
      click_on "Create"
    end

    # Wait for the create to land before navigating away. `click_on` does not wait for the POST
    # and its redirect, so the navigation could still be in flight when the `visit` below fires;
    # whichever won decided which page the assertions ran against. The group holds one case, so
    # the flash names one court date.
    expect(page).to have_text("1 court date created!")

    visit casa_case_path(casa_case)

    # Anchor on the case page before asserting its contents: hearing_type.name also appears in
    # the bulk form's "Hearing type" <select>, so a bare have_content could be satisfied by the
    # page we just left and never wait for this one.
    expect(page).to have_css("h1", text: "Case #{casa_case.case_number}")

    # Scoped to the elements that actually carry these values -- the court-date row link
    # ("<date> - <hearing type>") and the court-orders table -- so no <option> or unrelated copy
    # can satisfy them.
    expect(page).to have_css("a", text: hearing_type.name)
    expect(page).to have_css("td", text: court_order_text)
    travel_back
  end
end

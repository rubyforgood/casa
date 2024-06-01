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

  it "is successful", js: true do
    case_group = build(:case_group, casa_org: casa_org)
    case_group.case_group_memberships.first.casa_case = casa_case
    case_group.save!

    travel_to now
    sign_in admin
    visit casa_cases_path
    click_on "New Bulk Court Date"

    select case_group.name, from: "Case Group"
    fill_in "court_date_date", with: :now
    fill_in "court_date_court_report_due_date", with: :now
    select judge.name, from: "Judge"
    select hearing_type.name, from: "Hearing type"

    click_on "Add a custom court order"
    text_area = first(:css, "textarea").native
    text_area.send_keys(court_order_text)
    page.find("select.implementation-status").find(:option, text: "Partially implemented").select_option

    within ".top-page-actions" do
      click_on "Create"
    end

    visit casa_case_path(casa_case)
    expect(page).to have_content(hearing_type.name)
    expect(page).to have_content(court_order_text)
  end
end

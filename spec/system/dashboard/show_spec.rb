require "rails_helper"

RSpec.describe "dashboard/show", type: :system do
  let(:volunteer) { create(:volunteer, display_name: "Bob Loblaw") }
  let(:casa_admin) { create(:casa_admin, display_name: "John Doe") }

  context "volunteer user" do
    before do
      sign_in volunteer
    end

    it "sees all their casa cases" do
      casa_case_1 = build(:casa_case, active: true, casa_org: volunteer.casa_org, case_number: "CINA-1")
      casa_case_2 = build(:casa_case, active: true, casa_org: volunteer.casa_org, case_number: "CINA-2")
      casa_case_3 = build(:casa_case, active: true, casa_org: volunteer.casa_org, case_number: "CINA-3")
      create(:case_assignment, volunteer: volunteer, casa_case: casa_case_1)
      create(:case_assignment, volunteer: volunteer, casa_case: casa_case_2)

      visit casa_cases_path
      expect(page).to have_text("My Cases")
      expect(page).to have_text(casa_case_1.case_number)
      expect(page).to have_text(casa_case_2.case_number)
      expect(page).not_to have_text(casa_case_3.case_number)
    end

    it "volunteer does not see his name in Cases table" do
      casa_case = build(:casa_case, active: true, casa_org: volunteer.casa_org, case_number: "CINA-1")
      create(:case_assignment, volunteer: volunteer, casa_case: casa_case)

      visit casa_cases_path

      expect(page).not_to have_css("td", text: "Bob Loblaw")
    end

    it "displays 'No active cases' when they don't have any assignments", :js do
      visit casa_cases_path
      expect(page).to have_text("My Cases")
      expect(page).not_to have_css("td", text: "Bob Loblaw")
      expect(page).not_to have_text("Detail View")
    end
  end

  context "the Needs your attention list" do
    let(:supervisor) { create(:supervisor) }

    before do
      3.times do
        vol = create(:volunteer, casa_org: supervisor.casa_org, supervisor: supervisor)
        kase = create(:casa_case, casa_org: supervisor.casa_org)
        create(:case_assignment, volunteer: vol, casa_case: kase, active: true)
      end
      sign_in supervisor
    end

    it "is a table with real columns, not tinted boxes or a stretched list" do
      visit root_path

      section = find("[aria-labelledby='attention-heading']")
      # Columns spend the card's width on data. As a list, each row was one or two short items flung
      # to opposite edges of a ~918px card, leaving a measured 645px void that read as an empty table.
      expect(section).to have_css("table tbody tr", count: 3)
      expect(section).to have_css("table thead th", minimum: 3)

      # Rows used to carry their own rose border, rose fill and a filled 40px icon tile nested inside
      # this card; a tint on every row signals nothing. Severity is stated once, by the heading.
      # Scoped to the row and its cells: an initials avatar may legitimately be bg-rose-100, since
      # avatar_color cycles a palette by volunteer id, so a section-wide "no rose" assertion fails at
      # random (it did -- 2 runs in 8).
      expect(section).to have_no_css("tr[class*='bg-rose'], tr[class*='border-rose']")
      expect(section).to have_no_css("td[class*='bg-rose'], td[class*='border-rose']")
      expect(section).to have_no_css("span.h-10")

      # One action per row -- the name beside it is identifying text, not a second link to the same page.
      section.all("table tbody tr").to_a.each { |row| expect(row.all("a").size).to eq 1 }
    end
  end

  context "admin user" do
    before do
      sign_in casa_admin
    end

    it "sees volunteer names in Cases table as a link" do
      casa_case = build(:casa_case, active: true, casa_org: volunteer.casa_org, case_number: "CINA-1")
      create(:case_assignment, volunteer: volunteer, casa_case: casa_case)

      visit casa_cases_path

      expect(page).to have_text("Bob Loblaw")
      expect(page).to have_link("Bob Loblaw")
      expect(page).to have_css("td", text: "Bob Loblaw")
    end
  end
end

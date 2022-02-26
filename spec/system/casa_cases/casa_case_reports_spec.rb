require "rails_helper"
require "stringio"

RSpec.describe "volunteer downloads court reports for case", type: :system do
  let(:volunteer) { create(:volunteer) }
  let(:casa_case) { create(:casa_case, :with_one_court_order, casa_org: volunteer.casa_org) }
  let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }

  let!(:court_dates) do
    [10, 30, 31, 90].map { |n| create(:court_date, casa_case: casa_case, date: n.days.ago) }
  end

  let!(:reports) do
    [5, 11, 23, 44, 91].map do |n|
      report = CaseCourtReport.new(
        volunteer_id: volunteer.id,
        case_id: casa_case.id,
        path_to_template: "app/documents/templates/default_report_template.docx"
        # path_to_template: "app/documents/templates/montgomery_report_template.docx"
        # path_to_template: "app/documents/templates/prince_george_report_template.docx"
      )
      casa_case.court_reports.attach(io: StringIO.new(report.generate_to_string), filename: "report#{n}.docx")
      attached_report = casa_case.latest_court_report
      attached_report.created_at = n.days.ago
      attached_report.save!
      attached_report
    end
  end

  before { sign_in volunteer }

  it "views and downloads", js: true do
    now = Date.new(2021, 1, 22)
    travel_to now do
      _case_contact_1 = create(:case_contact, casa_case: casa_case, occurred_at: Date.new(2021, 1, 1))
      _court_date_1 = create(:court_date, casa_case: casa_case, date: Date.new(2021, 1, 10))
      _case_contact_2 = create(:case_contact, casa_case: casa_case, occurred_at: Date.new(2021, 1, 20))
      # now
      _court_date_2 = create(:court_date, casa_case: casa_case, date: Date.new(2021, 1, 21))
      _case_contact_3 = create(:case_contact, casa_case: casa_case, occurred_at: Date.new(2021, 1, 22))
      _court_date_future = create(:court_date, casa_case: casa_case, date: Date.new(2021, 3, 3))

      sign_in volunteer
      visit casa_case_path(casa_case)

      expect(page).to have_link("January 10, 2021")
      expect(page).to have_link("January 21, 2021")
      expect(page).to have_link("March 3, 2021")
      expect(page).to have_link("November 25, 2021")
      expect(page).to have_link("January 23, 2022")
      expect(page).to have_link("January 24, 2022")
      expect(page).to have_link("February 13, 2022")

      click_on "February 13, 2022"
      # assert on downloaded file
    end
  end
end

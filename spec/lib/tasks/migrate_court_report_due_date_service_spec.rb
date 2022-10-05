require "rails_helper"
require_relative "../../../lib/tasks/migrate_court_report_due_date_service"
require "support/stubbed_requests/webmock_helper"

RSpec.describe MigrateCourtReportDueDateService do
  it "should update dates" do
    casa_case_without_court_dates = create :casa_case
    casa_case_with_court_date = create :casa_case, :with_upcoming_court_date
    described_class.new.run!
    expect(casa_case_without_court_dates.court_dates).to eq([])
    expect(casa_case_with_court_date.court_dates.last).to be_present # ??
  end
end

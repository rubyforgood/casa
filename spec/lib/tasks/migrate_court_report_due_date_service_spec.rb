require "rails_helper"
require_relative "../../../lib/tasks/migrate_court_report_due_date_service"
require "support/stubbed_requests/webmock_helper"

RSpec.describe MigrateCourtReportDueDateService do
  it "should update dates" do
    casa_case_with_court_date = create :casa_case, :with_upcoming_court_date
    casa_case_with_court_date.court_report_due_date = Date.today
    casa_case_with_court_date.save
    expect(casa_case_with_court_date.court_dates.last.court_report_due_date).to be_nil
    described_class.new.run!
    expect(casa_case_with_court_date.reload.court_dates.last.court_report_due_date).not_to be_nil
    expect(casa_case_with_court_date.court_dates.last).to be_present # ??
  end

  it "should not error when there are no dates" do
    _casa_case_without_court_dates = create :casa_case
    expect { described_class.new.run! }.not_to raise_error
  end
end

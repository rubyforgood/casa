# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#

every 1.day, at: "11:00 am" do
  rake "send_supervisor_digest"
end

every 1.day, at: "3:00 pm" do
  rake "court_report_due_reminder"
end

every 1.day, at: "11:00 pm" do
  rake "clear_passed_dates"
end

every 1.day, at: "11:00 pm" do
  rake "emancipation_checklist_reminder"
end

# Learn more: http://github.com/javan/whenever

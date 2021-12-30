class ExampleRecurringTask
  include Delayed::RecurringJob
  run_every 1.day
  run_at "11:00am"
  timezone "US/Pacific"

  def perform
    Bugsnag.notify("This is just ExampleRecurringTask saying hi in #{Rails.env}")
  end
end

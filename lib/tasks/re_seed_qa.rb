class ReSeedQa
  include Delayed::RecurringJob
  run_every 1.day
  run_at '11:00am'
  timezone 'US/Pacific'

  def perform
    Rake.application['mytask'].invoke('one')
  end
end
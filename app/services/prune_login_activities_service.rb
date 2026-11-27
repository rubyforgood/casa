# frozen_string_literal: true

# Prunes login_activities records older than the retention window (default: 13 months).
# Written by AuthTrail on every sign-in attempt, login_activities accumulates personal data
# (typed email identities, IP addresses, user agents) indefinitely.
#
# The retention window defaults to 13 months and enforces a hard minimum of 13 months so that
# the 12-month historical reporting window on the Metrics page (MetricsReport#monthly_active_users)
# is never clipped, even on the last day of the current month.
class PruneLoginActivitiesService
  DEFAULT_RETENTION_MONTHS = 13
  MINIMUM_RETENTION_MONTHS = 13

  def initialize(months: DEFAULT_RETENTION_MONTHS)
    @months = parse_months(months)
  end

  def perform
    prunable.in_batches.delete_all
  end

  private

  attr_reader :months

  def parse_months(months)
    raise ArgumentError, "retention months cannot be nil" if months.nil?
    raise ArgumentError, "retention months must be a whole number, got #{months.inspect}" if months.is_a?(Numeric) && !months.is_a?(Integer)

    parsed = begin
      Integer(months)
    rescue ArgumentError, TypeError
      raise ArgumentError, "retention months must be a valid whole number, got #{months.inspect}"
    end

    if parsed < MINIMUM_RETENTION_MONTHS
      raise ArgumentError, "retention window must be at least #{MINIMUM_RETENTION_MONTHS} months, got #{parsed}"
    end

    parsed
  end

  def prunable
    LoginActivity.where(created_at: ...months.months.ago)
  end
end

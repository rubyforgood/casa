# Headless policy for the per-chapter Analytics page. Gated to admins and supervisors
# (volunteers do not see chapter-wide analytics), matching the Reports page audience.
class AnalyticsPolicy < ApplicationPolicy
  def index?
    admin_or_supervisor?
  end
end

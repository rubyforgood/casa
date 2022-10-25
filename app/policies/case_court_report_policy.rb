class CaseCourtReportPolicy < ApplicationPolicy
  def index?
    user.casa_admin? || user.supervisor? || user.volunteer?
  end

  alias_method :show?, :index?
  alias_method :generate?, :index?
end

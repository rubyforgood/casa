class DashboardPolicy < ApplicationPolicy
  def all_allowed
    true
  end

  def is_admin?
    user.casa_admin?
  end

  def create_case_contacts?
    # TODO this is not really permissions, probably move it out of policyfile
    user.volunteer? && user.casa_cases.size > 0
  end

  alias_method :see_volunteers_section?, :is_admin?
  alias_method :see_admins_section?, :is_admin?
  alias_method :show?, :all_allowed
  alias_method :see_cases_section?, :all_allowed
end

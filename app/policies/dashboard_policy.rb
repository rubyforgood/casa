class DashboardPolicy
  attr_reader :user, :dashboard

  def initialize(user, dashboard)
    @user = user
    @dashboard = dashboard
  end

  def show?
    true
  end

  def see_volunteers_section?
    user.casa_admin?
  end

  def create_case_contacts?
    user.volunteer? && user.casa_cases.size > 0
  end

  alias_method :see_admins_section?, :see_volunteers_section?
  alias_method :see_cases_section?, :show?
end

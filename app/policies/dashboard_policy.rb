class DashboardPolicy
  include PolicyHelper
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
    user.role == "volunteer"
  end

  def see_cases_section?
    true
  end
end

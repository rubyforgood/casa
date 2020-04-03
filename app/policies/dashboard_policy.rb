class DashboardPolicy < Struct.new(:user, :dashboard)
  def show?
    true
  end

  def see_volunteers_section?
    user.casa_admin?
  end

  def see_cases_section?
    true
  end
end

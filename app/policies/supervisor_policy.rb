class SupervisorPolicy < UserPolicy
  def index?
    admin_or_supervisor?
  end

  def create?
    is_admin?
  end
end

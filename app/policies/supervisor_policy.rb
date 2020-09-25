class SupervisorPolicy < UserPolicy
  def index?
    user&.casa_admin? || user&.supervisor?
  end

  def create?
    user&.casa_admin?
  end
end

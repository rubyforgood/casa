class SupervisorPolicy < UserPolicy
  def index?
    user&.casa_admin? || user&.supervisor?
  end
end

class SupervisorPolicy < UserPolicy
  def index?
    admin_or_supervisor?
  end

  def new?
    is_admin?
  end

  def update?
    is_admin? ||
      (is_supervisor? && record == user)
  end

  alias_method :create?, :new?
  alias_method :edit?, :index?
end

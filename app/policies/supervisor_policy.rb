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

  def activate?
    is_admin?
  end

  def deactivate?
    is_admin?
  end

  def resend_invitation?
    is_admin?
  end

  def edit?
    admin_or_supervisor_same_org?
  end

  alias_method :create?, :new?
  alias_method :datatable?, :index?
  alias_method :change_to_admin?, :is_admin?
end

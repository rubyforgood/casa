class SupervisorPolicy < UserPolicy
  def index?
    admin_or_supervisor? && admin_belongs_to_supervisor_org?
  end

  def new?
    is_admin?
  end

  def update?
    (is_admin? || (is_supervisor? && record == user)) && same_org?
  end

  def activate?
    is_admin? && admin_belongs_to_supervisor_org?
  end

  def deactivate?
    is_admin? && admin_belongs_to_supervisor_org?
  end

  def resend_invitation?
    is_admin? && admin_belongs_to_supervisor_org?
  end

  def edit?
    admin_or_supervisor_same_org?
  end

  alias_method :create?, :new?
  alias_method :datatable?, :index?
  alias_method :change_to_admin?, :is_admin?

  private

  def admin_belongs_to_supervisor_org?
    record.joins(:casa_org).map(&:casa_org_id).include?(user.casa_org_id)
  end
end

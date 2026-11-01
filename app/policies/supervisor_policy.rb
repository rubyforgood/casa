class SupervisorPolicy < UserPolicy
  class Scope < ApplicationPolicy::Scope
    # Filtering only. Callers preload what their page needs: eager-loading volunteers' case_contacts
    # here pulled every contact in the org into memory on /supervisors and /volunteers (#7279).
    def resolve
      scope
    end
  end

  def index?
    admin_or_supervisor?
  end

  def new?
    is_admin?
  end

  def update?
    (is_admin? || (is_supervisor? && record == user)) && same_org?
  end

  def activate?
    is_admin_same_org?
  end

  def deactivate?
    is_admin_same_org?
  end

  def resend_invitation?
    is_admin_same_org?
  end

  def edit?
    admin_or_supervisor_same_org?
  end

  alias_method :create?, :new?
  alias_method :change_to_admin?, :is_admin_same_org?
end

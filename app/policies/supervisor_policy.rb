class SupervisorPolicy < UserPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.includes(
        :volunteers,
        volunteers: [:supervisor, :case_assignments, :case_contacts]
      )
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
  alias_method :datatable?, :index?
  alias_method :change_to_admin?, :is_admin?
end

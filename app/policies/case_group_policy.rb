class CaseGroupPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      case user
      when CasaAdmin, Supervisor
        scope.where(casa_org: @user.casa_org)
      when Volunteer
        scope.none
      else
        scope.none
      end
    end
  end

  def index?
    is_admin? || is_supervisor?
  end

  def new?
    admin_or_supervisor_same_org?
  end

  def show?
    admin_or_supervisor_same_org?
  end

  def create?
    admin_or_supervisor_same_org?
  end

  def edit?
    admin_or_supervisor_same_org?
  end

  def update?
    admin_or_supervisor_same_org?
  end

  def destroy?
    admin_or_supervisor_same_org?
  end

  def same_org?
    user&.casa_org.present? && user&.casa_org == record&.casa_org
  end
end

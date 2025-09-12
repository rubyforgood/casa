class PlacementTypePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      case user
      when CasaAdmin
        scope.where(casa_org: @user.casa_org)
      when Volunteer, Supervisor
        scope.none
      else
        scope.none
      end
    end
  end

  def edit?
    is_admin_same_org?
  end

  alias_method :new?, :edit?
  alias_method :create?, :edit?
  alias_method :update?, :edit?
end

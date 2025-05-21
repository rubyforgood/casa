class CustomOrgLinkPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      case user
      when CasaAdmin
        scope.where(casa_org: @user.casa_org)
      else
        scope.none
      end
    end
  end
end

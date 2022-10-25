class HearingTypePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      case @user
      when CasaAdmin
        scope.where(casa_org_id: @user.casa_org.id)
      end
    end
  end
end

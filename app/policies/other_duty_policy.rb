class OtherDutyPolicy < UserPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.where(casa_org_id: user.casa_org_id)
    end
  end

  def index?
    admin_or_supervisor?
  end
end

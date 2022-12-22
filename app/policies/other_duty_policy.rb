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

  def new?
    user.volunteer?
  end

  def create?
    new?
  end

  def edit?
    user.volunteer? && record.creator == user
  end

  def update?
    edit?
  end
end

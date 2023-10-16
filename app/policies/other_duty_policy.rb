class OtherDutyPolicy < UserPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end
  end

  def index?
    admin_or_supervisor_or_volunteer?
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

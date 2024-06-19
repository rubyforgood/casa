class OtherDutyPolicy < UserPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end
  end

  def index?
    admin_or_supervisor_or_volunteer? && casa_org_other_duties_enabled?
  end

  def new?
    user.volunteer? && casa_org_other_duties_enabled?
  end

  def create?
    new?
  end

  def edit?
    user.volunteer? && record.creator == user && casa_org_other_duties_enabled?
  end

  def update?
    edit?
  end

  def casa_org_other_duties_enabled?
    user.casa_org.other_duties_enabled
  end
end

class UserPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def update_volunteer_email?
    user.casa_admin?
  end

  def unassign_case?
    user.casa_admin? || user.supervisor?
  end

  alias_method :activate?, :unassign_case?

  def deactivate?
    activate?
  end

  def update_supervisor_email?
    user.casa_admin? || record == user
  end

  def update_supervisor_name?
    update_supervisor_email?
  end

  def edit_name?(viewed_user)
    user.casa_admin? || viewed_user == user
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      case user
      when CasaAdmin, Supervisor # TODO scope.in_casa_administered_by(user)
        scope.all
      when Volunteer
        scope.where(id: user.id)
      else
        raise "unrecognized role #{@user.type}"
      end
    end

    def edit?
      case user
      when CasaAdmin, Supervisor # TODO scope.in_casa_administered_by(user)
        scope.all
      when Volunteer
        scope.where(id: user.id)
      else
        raise "unrecognized role #{@user.type}"
      end
    end
  end
end

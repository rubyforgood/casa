class UserPolicy
  include PolicyHelper
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def update_supervisor_email?
    user.casa_admin? || record == user
  end

  def update_supervisor_name?
    update_supervisor_email?
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      case user
      when CasaAdmin # scope.in_casa_administered_by(user)
        scope.all
      when Volunteer
        scope.where(id: user.id)
      when Supervisor
        scope.all
      else
        raise "unrecognized role #{@user.role}"
      end
    end
  end
end

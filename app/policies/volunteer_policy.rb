class VolunteerPolicy < UserPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      case user
      when CasaAdmin, Supervisor, Volunteer
        scope.by_organization(@user.casa_org)
      else
        raise "unrecognized role #{@user.type}"
      end
    end
  end

  def index?
    admin_or_supervisor?
  end

  def impersonate?
    admin_or_supervisor?
  end

  def stop_impersonating?
    admin_or_supervisor_or_volunteer?
  end

  alias_method :datatable?, :index?
  alias_method :new?, :index?
  alias_method :create?, :index?
  alias_method :edit?, :index?
  alias_method :update?, :index?
  alias_method :activate?, :index?
  alias_method :deactivate?, :index?
  alias_method :resend_invitation?, :index?
  alias_method :reminder?, :index?
end

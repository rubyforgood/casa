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

  def edit?
    admin_or_supervisor_same_org?
  end

  def impersonate?
    admin_or_supervisor_same_org?
  end

  def stop_impersonating?
    admin_or_supervisor_or_volunteer?
  end

  alias_method :datatable?, :index?
  alias_method :new?, :admin_or_supervisor_same_org?
  alias_method :create?, :admin_or_supervisor_same_org?
  alias_method :show?, :admin_or_supervisor_same_org?
  alias_method :update?, :admin_or_supervisor_same_org?
  alias_method :activate?, :admin_or_supervisor_same_org?
  alias_method :deactivate?, :admin_or_supervisor_same_org?
  alias_method :resend_invitation?, :admin_or_supervisor_same_org?
  alias_method :send_reactivation_alert?, :admin_or_supervisor_same_org?
  alias_method :reminder?, :admin_or_supervisor_same_org?
end

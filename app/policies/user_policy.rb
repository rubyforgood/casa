class UserPolicy < ApplicationPolicy
  def add_language?
    admin_or_supervisor_same_org? || record == user
  end

  def edit?
    admin_or_supervisor_or_volunteer?
  end

  def update_volunteer_email?
    admin_or_supervisor?
  end

  def unassign_case?
    admin_or_supervisor?
  end

  alias_method :activate?, :unassign_case?

  def deactivate?
    activate?
  end

  def update_supervisor_email?
    is_admin? || record == user
  end

  def update_supervisor_name?
    update_supervisor_email?
  end

  def update_user_setting?
    if is_supervisor_same_org?
      # allow access to own record or volunteer record
      return record == user || record.volunteer?
    end
    is_admin?
  end

  def edit_name?(viewed_user)
    is_admin? || viewed_user == user
  end

  alias_method :update?, :edit?
  alias_method :update_password?, :edit?
  alias_method :update_email?, :edit?

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      case user
      when CasaAdmin, Supervisor # scope.in_casa_administered_by(user)
        scope.by_organization(@user.casa_org)
      when Volunteer
        scope.where(id: user.id)
      else
        raise "unrecognized role #{@user.type}"
      end
    end

    alias_method :edit?, :resolve
  end
end

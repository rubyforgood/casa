class UserPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      case user
      when CasaAdmin, Supervisor # scope.in_casa_administered_by(user)
        scope.by_organization user.casa_org
      when Volunteer
        scope.where(id: user.id)
      else
        raise "unrecognized role #{user.type}"
      end
    end
  end

  def add_language?
    self? || admin_or_supervisor_same_org?
  end
  alias_method :remove_language?, :add_language?

  def edit?
    # TODO use && same_org here! (or similar method from ApplicationPolicy)
    admin_or_supervisor_or_volunteer?
  end
  alias_method :update?, :edit?
  alias_method :update_password?, :edit?
  alias_method :update_email?, :edit?

  def unassign_case?
    admin_or_supervisor?
  end

  alias_method :activate?, :unassign_case?
  alias_method :update_volunteer_email?, :unassign_case?

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
    return true if is_admin? # should be same org

    return false unless is_supervisor_same_org?

    self? || record.volunteer?
  end

  def edit_name?(viewed_user)
    # record passed in as viewed_user parameter here. atypical. fix?
    is_admin? || viewed_user == user
  end

  private

  def self?
    user == record
  end
end

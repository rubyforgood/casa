class CaseContactPolicy < ApplicationPolicy
  def new?
    is_creator? || admin_or_supervisor_same_org?
  end

  def show?
    creator_or_admin?
  end

  def update?
    creator_or_supervisor_or_admin?
  end

  def destroy?
    admin_or_supervisor_same_org? || (is_creator? && is_draft?)
  end

  def additional_expenses_allowed?
    Flipper.enabled?(:show_additional_expenses) &&
      current_organization.additional_expenses_enabled
  end

  alias_method :index?, :admin_or_supervisor_or_volunteer?
  alias_method :drafts?, :admin_or_supervisor?
  alias_method :edit?, :update?
  alias_method :restore?, :is_admin_same_org?

  class Scope < ApplicationPolicy::Scope
    def resolve
      case user
      when CasaAdmin, Supervisor
        scope.joins(:creator).where(creator: {casa_org: user.casa_org})
      when Volunteer
        scope.where(creator: user)
      else
        scope.none
      end
    end
  end

  private

  def creator_or_admin?
    is_creator? || is_admin_same_org?
  end

  def creator_or_supervisor_or_admin?
    is_creator? || admin_or_supervisor_same_org?
  end

  def is_draft?
    !record.active?
  end

  def is_creator?
    record.creator == user
  end

  def same_org?
    record_org = record.casa_org || record.creator_casa_org
    user&.casa_org_id == record_org&.id
  end
end

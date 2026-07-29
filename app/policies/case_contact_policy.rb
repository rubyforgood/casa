class CaseContactPolicy < ApplicationPolicy
  def new?
    is_creator? || admin_or_supervisor_same_org?
  end

  def show?
    creator_or_supervisor_or_admin?
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
  # The form persists on first save rather than on open, so creating is the same permission as
  # opening the form. Without this, create fell through to ApplicationPolicy#create? (admin only).
  alias_method :create?, :new?
  alias_method :edit?, :update?
  # Discarding a draft is the same permission as deleting it (creator of a draft, or an
  # admin/supervisor in the org). Named for the action so Pundit resolves it without an explicit
  # query, like every other alias here.
  alias_method :discard_draft?, :destroy?
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

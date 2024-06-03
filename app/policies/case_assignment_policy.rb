class CaseAssignmentPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all # TODO limit to one CASA
    end
  end

  def create?
    admin_or_supervisor?
  end

  def destroy?
    admin_or_supervisor? && same_org?
  end

  def unassign?
    record.active? && admin_or_supervisor? && same_org?
  end

  def reimbursement?
    admin_or_supervisor? && same_org?
  end

  def hide_contacts?
    show_or_hide_contacts? && !record.hide_old_contacts?
  end

  def show_or_hide_contacts?
    !record.active? && admin_or_supervisor? && same_org?
  end

  def same_org?
    user.casa_org_id == record.casa_case.casa_org_id
  end
end

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
    admin_or_supervisor?
  end

  def unassign?
    record.active? && admin_or_supervisor?
  end

  def hide_contacts?
    !record.active? && !record.hide_old_contacts? && admin_or_supervisor?
  end

  def show_or_hide_contacts?
    hide_contacts? || !hide_contacts?
  end
end

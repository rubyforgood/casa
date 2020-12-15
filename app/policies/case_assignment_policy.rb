class CaseAssignmentPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end

  def unassign?
    record.is_active? && admin_or_supervisor?
  end
end

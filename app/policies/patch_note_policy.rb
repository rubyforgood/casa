class PatchNotePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.notes_available_for_user(@user)
    end
  end
end

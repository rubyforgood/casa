class FollowupPolicy < ApplicationPolicy
  def create?
    admin_or_supervisor_or_volunteer?
  end

  alias_method :resolve?, :create?
end

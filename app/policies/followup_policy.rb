class FollowupPolicy < ApplicationPolicy
  def create?
    admin_or_supervisor_or_volunteer?
  end
end

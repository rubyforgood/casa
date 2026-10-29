class FollowupPolicy < ApplicationPolicy
  def create?
    admin_or_supervisor_or_volunteer?
  end

  def resolve?
    admin_or_supervisor_or_volunteer_same_org?
  end
end

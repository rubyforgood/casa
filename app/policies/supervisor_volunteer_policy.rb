class SupervisorVolunteerPolicy < ApplicationPolicy
  def create?
    user.casa_admin? || user.supervisor? || user.volunteer?
  end

  def unassign?
    user.casa_admin? || user.supervisor?
  end

  def bulk_assignment? 
    user.casa_admin? || user.supervisor? 
  end 
end

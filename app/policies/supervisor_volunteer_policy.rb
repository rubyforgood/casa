class SupervisorVolunteerPolicy < Struct.new(:user, :record)
  def create?
    user.casa_admin? || user.supervisor? || user.volunteer?
  end

  def unassign?
    user.casa_admin? || user.supervisor?
  end
end

class VolunteerPolicy < UserPolicy
  include PolicyHelper
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def update_volunteer_email?
    user.casa_admin?
  end

  def unassign_case?
    user.casa_admin? || user.supervisor?
  end
end

class VolunteerPolicy
  include PolicyHelper
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def update_volunteer_email?
    user.casa_admin?
  end

  def activate?
    @user.casa_admin? || @record.supervisor == @user
  end

  def deactivate?
    activate?
  end
end

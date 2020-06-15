class SupervisorPolicy
  include PolicyHelper
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def update_supervisor_email?
    user.casa_admin? || user == record
  end
end

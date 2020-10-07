class VolunteerPolicy < UserPolicy
  attr_reader :user, :record

  def index?
    user.casa_admin? || user.supervisor?
  end

  def new?
    create?
  end

  def create?
    user.casa_admin?
  end

  def initialize(user, record)
    @user = user
    @record = record
  end
end

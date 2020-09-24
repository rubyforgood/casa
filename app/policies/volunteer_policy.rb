class VolunteerPolicy < UserPolicy
  attr_reader :user, :record

  def index?
    user&.volunteer?
  end

  def initialize(user, record)
    @user = user
    @record = record
  end
end

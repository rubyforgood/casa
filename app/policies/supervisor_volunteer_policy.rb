class SupervisorVolunteerPolicy # rubocop:todo Style/Documentation
  include PolicyHelper
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    is_casa_admin_of_org?(user, record)
  end

  def show?
    is_casa_admin_of_org?(user, record)
  end

  def create?
    is_casa_admin_of_org?(user, record)
  end

  def new?
    is_casa_admin_of_org?(user, record)
  end

  def update?
    is_casa_admin_of_org?(user, record)
  end

  def edit?
    is_casa_admin_of_org?(user, record)
  end

  def destroy?
    is_casa_admin_of_org?(user, record)
  end
end

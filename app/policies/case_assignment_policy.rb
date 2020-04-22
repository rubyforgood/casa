class CaseAssignmentPolicy
  include PolicyHelper
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    casa_admin_of_org?(user, record)
  end

  def show?
    casa_admin_of_org?(user, record)
  end

  def create?
    casa_admin_of_org?(user, record)
  end

  def new?
    casa_admin_of_org?(user, record)
  end

  def update?
    casa_admin_of_org?(user, record)
  end

  def edit?
    casa_admin_of_org?(user, record)
  end

  def destroy?
    casa_admin_of_org?(user, record)
  end
end

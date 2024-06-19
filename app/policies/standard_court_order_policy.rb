class StandardCourtOrderPolicy < ApplicationPolicy
  def create?
    is_admin_same_org?
  end

  def new?
    is_admin_same_org?
  end

  def update?
    is_admin_same_org?
  end

  def edit?
    is_admin_same_org?
  end

  def destroy?
    is_admin_same_org?
  end
end
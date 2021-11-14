class ReimbursementPolicy < ApplicationPolicy
  def index?
    is_admin?
  end

  def change_complete_status?
    index?
  end
end

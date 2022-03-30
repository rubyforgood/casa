class ReimbursementPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      # scope must INNER JOIN casa_case
      scope.where(casa_case: {casa_org_id: user.casa_org.id})
    end
  end

  def index?
    is_admin?
  end

  def datatable?
    is_admin?
  end

  def change_complete_status?
    index?
  end
end
